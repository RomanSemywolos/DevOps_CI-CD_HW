resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace

    labels = merge({
      name        = var.namespace
      environment = var.environment
      project     = var.project_name
    }, var.tags)
  }
}

resource "helm_release" "prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.prometheus_chart_version

  namespace = kubernetes_namespace.monitoring.metadata[0].name

  values = [
    var.prometheus_values_file != "" ?
    file(var.prometheus_values_file)
    :
    templatefile("${path.module}/values.yaml", {
      prometheus_retention      = var.prometheus_retention
      prometheus_storage_size   = var.prometheus_storage_size
      grafana_storage_size      = var.grafana_storage_size
      alertmanager_storage_size = var.alertmanager_storage_size

      grafana_admin_password = var.grafana_admin_password

      enable_alertmanager       = var.enable_alertmanager
      enable_node_exporter      = var.enable_node_exporter
      enable_kube_state_metrics = var.enable_kube_state_metrics

      slack_webhook_url = var.slack_webhook_url
      slack_channel     = var.slack_channel

      create_ingress        = var.create_ingress
      grafana_hostname      = var.grafana_hostname
      prometheus_hostname   = var.prometheus_hostname
      alertmanager_hostname = var.alertmanager_hostname
    })
  ]

  create_namespace = false
  timeout = 600

  depends_on = [kubernetes_namespace.monitoring]
}

resource "kubernetes_manifest" "django_service_monitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"

    metadata = {
      name      = "${var.project_name}-django-metrics"
      namespace = var.namespace
      labels = {
        app         = "${var.project_name}-django"
        environment = var.environment
      }
    }

    spec = {
      selector = {
        matchLabels = {
          app = "${var.project_name}-django"
        }
      }

      endpoints = [
        {
          port     = "http"
          path     = "/metrics"
          interval = "30s"
        }
      ]

      namespaceSelector = {
        matchNames = ["default"]
      }
    }
  }

  depends_on = [helm_release.prometheus_stack]
}

resource "kubernetes_config_map" "prometheus_rules" {
  metadata {
    name      = "${var.project_name}-prometheus-rules"
    namespace = var.namespace

    labels = {
      app         = "prometheus"
      environment = var.environment
      project     = var.project_name
    }
  }

  data = {
    "custom-rules.yaml" = yamlencode({
      groups = [
        {
          name = "${var.project_name}-alerts"
          rules = [
            {
              alert = "HighMemoryUsage"
              expr  = "container_memory_usage_bytes / container_spec_memory_limit_bytes > 0.8"
              for   = "5m"
              labels = { severity = "warning" }
              annotations = {
                summary     = "High memory usage detected"
                description = "Container {{ $labels.container }} in pod {{ $labels.pod }} using >80% memory"
              }
            },
            {
              alert = "HighCPUUsage"
              expr  = "rate(container_cpu_usage_seconds_total[5m]) > 0.8"
              for   = "5m"
              labels = { severity = "warning" }
              annotations = {
                summary     = "High CPU usage detected"
                description = "Container {{ $labels.container }} in pod {{ $labels.pod }} using >80% CPU"
              }
            }
          ]
        }
      ]
    })
  }

  depends_on = [kubernetes_namespace.monitoring]
}

resource "kubernetes_secret" "alertmanager_config" {
  count = var.enable_alertmanager && var.slack_webhook_url != "" ? 1 : 0

  metadata {
    name      = "alertmanager-${helm_release.prometheus_stack.name}-kube-prom-alertmanager"
    namespace = var.namespace
  }

  data = {
    "alertmanager.yml" = yamlencode({
      global = {
        slack_api_url = var.slack_webhook_url
      }

      route = {
        group_by        = ["alertname"]
        group_wait      = "10s"
        group_interval  = "10s"
        repeat_interval = "1h"
        receiver        = "slack-notifications"
      }

      receivers = [
        {
          name = "slack-notifications"
          slack_configs = [
            {
              channel       = var.slack_channel
              title         = "[{{ .Status | toUpper }}] {{ .GroupLabels.alertname }}"
              text          = "{{ range .Alerts }}{{ .Annotations.summary }} - {{ .Annotations.description }}{{ end }}"
              send_resolved = true
            }
          ]
        }
      ]
    })
  }

  depends_on = [helm_release.prometheus_stack]
}
