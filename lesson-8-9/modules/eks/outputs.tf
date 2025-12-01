output "eks_cluster_endpoint" {
  description = "EKS API endpoint для підключення до кластера"
  value       = aws_eks_cluster.eks.endpoint
}

output "eks_cluster_name" {
  description = "Назва EKS кластера"
  value       = aws_eks_cluster.eks.name
}

output "eks_node_role_arn" {
  description = "IAM role ARN для worker-нoд"
  value       = aws_iam_role.nodes.arn
}

# Ці output'и очікуються aws_ebs_csi_driver.tf (якщо він як у попередніх уроках)
output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.oidc.arn
}

output "oidc_provider_url" {
  value = aws_iam_openid_connect_provider.oidc.url
}

output "ebs_csi_driver_role" {
  value = aws_iam_role.ebs_csi_irsa_role.arn
}

output "eks_nodes_sg_id" {
  description = "Security Group ID для worker-нoд EKS (використовується RDS)"
  value       = aws_security_group.eks_nodes_sg.id
}
