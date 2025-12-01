variable "kubeconfig" {
  description = "Path to kubeconfig file (not used directly, kept for compatibility)"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  type        = string
}

variable "oidc_provider_url" {
  description = "OIDC provider URL for IRSA"
  type        = string
}
