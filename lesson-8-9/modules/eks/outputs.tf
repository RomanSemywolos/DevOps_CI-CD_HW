output "eks_cluster_endpoint" {
  description = "EKS API endpoint for connecting to the cluster"
  value       = aws_eks_cluster.eks.endpoint
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.eks.name
}

output "eks_node_role_arn" {
  description = "IAM role ARN for EKS Worker Nodes"
  value       = aws_iam_role.nodes.arn
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN for the EKS cluster"
  value       = aws_iam_openid_connect_provider.oidc.arn
}

output "oidc_provider_url" {
  description = "OIDC provider URL for the EKS cluster"
  value       = aws_iam_openid_connect_provider.oidc.url
}

output "ebs_csi_driver_role" {
  description = "IAM role ARN used by the EBS CSI Driver"
  value       = aws_iam_role.ebs_csi_irsa_role.arn
}
