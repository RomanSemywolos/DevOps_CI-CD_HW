output "namespace" {
  value = kubernetes_namespace.monitoring.metadata[0].name
}

output "grafana_url" {
  value = "http://localhost:3000"
}

output "prometheus_url" {
  value = "http://localhost:9090"
}

output "alertmanager_url" {
  value = var.enable_alertmanager ? "http://localhost:9093" : null
}

output "port_forward_commands" {
  value = {
    grafana    = "kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n ${var.namespace}"
    prometheus = "kubectl port-forward svc/kube-prometheus-stack-kube-prom-prometheus 9090:9090 -n ${var.namespace}"
    alertmgr   = var.enable_alertmanager ? "kubectl port-forward svc/kube-prometheus-stack-kube-prom-alertmanager 9093:9093 -n ${var.namespace}" : null
  }
}
