variable "name" {
  description = "Helm release name for Argo CD"
  type        = string
  default     = "argo-cd"
}

variable "namespace" {
  description = "K8s namespace for Argo CD"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Argo CD chart version"
  type        = string
  default     = "5.46.4"
}
