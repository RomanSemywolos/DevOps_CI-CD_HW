variable "namespace" {
  type        = string
  default     = "monitoring"
}

variable "prometheus_chart_version" {
  type    = string
  default = "55.5.0"
}

variable "prometheus_values_file" {
  type    = string
  default = ""
}

variable "grafana_admin_password" {
  type        = string
  sensitive   = true
}

variable "prometheus_retention" {
  type    = string
  default = "15d"
}

variable "prometheus_storage_size" {
  type    = string
  default = "10Gi"
}

variable "grafana_storage_size" {
  type    = string
  default = "5Gi"
}

variable "alertmanager_storage_size" {
  type    = string
  default = "2Gi"
}

variable "enable_node_exporter" {
  type    = bool
  default = true
}

variable "enable_kube_state_metrics" {
  type    = bool
  default = true
}

variable "enable_alertmanager" {
  type    = bool
  default = true
}

variable "slack_webhook_url" {
  type      = string
  sensitive = true
}

variable "slack_channel" {
  type    = string
  default = "#alerts"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "project_name" {
  type    = string
  default = "djangoapp"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "create_ingress" {
  type    = bool
  default = false
}

variable "grafana_hostname" {
  type    = string
  default = "grafana.example.com"
}

variable "prometheus_hostname" {
  type    = string
  default = "prometheus.example.com"
}

variable "alertmanager_hostname" {
  type    = string
  default = "alertmanager.example.com"
}
