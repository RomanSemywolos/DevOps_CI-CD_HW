# S3 backend outputs

output "s3_bucket_name" {
  description = "Назва S3-бакета для Terraform state"
  value       = module.s3_backend.s3_bucket_name
}

output "dynamodb_table_name" {
  description = "Назва DynamoDB таблиці для блокування state"
  value       = module.s3_backend.dynamodb_table_name
}

# VPC outputs

output "vpc_id" {
  description = "ID VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "Список публічних підмереж"
  value       = module.vpc.public_subnet_ids
}

output "private_subnets" {
  description = "Список приватних підмереж"
  value       = module.vpc.private_subnet_ids
}

output "internet_gateway_id" {
  description = "ID Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

# ECR

output "ecr_repository_url" {
  description = "URL ECR репозиторію"
  value       = module.ecr.repository_url
}

# EKS

output "eks_cluster_name" {
  description = "Назва EKS кластера"
  value       = module.eks.eks_cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS API endpoint"
  value       = data.aws_eks_cluster.eks.endpoint
}

output "eks_cluster_ca" {
  description = "Сертифікат CA кластера"
  value       = data.aws_eks_cluster.eks.certificate_authority[0].data
}

output "eks_nodes_sg" {
  description = "Security Group worker-нoд"
  value       = module.eks.eks_nodes_sg_id
}

# Jenkins outputs

output "jenkins_service_name" {
  description = "Назва сервісу Jenkins"
  value       = module.jenkins.jenkins_service_name
}

output "jenkins_admin_password" {
  description = "Пароль адміністратора Jenkins"
  value       = module.jenkins.jenkins_admin_password
  sensitive   = true
}

# ArgoCD

output "argocd_server_hostname" {
  description = "Ingress hostname Argo CD (якщо увімкнено)"
  value       = module.argo_cd.argocd_server_hostname
}

output "argocd_namespace" {
  description = "Namespace Argo CD"
  value       = module.argo_cd.namespace
}

# RDS / Aurora

output "rds_endpoint" {
  description = "Primary endpoint RDS"
  value       = module.rds.endpoint
}

output "aurora_writer" {
  description = "Writer endpoint Aurora"
  value       = module.rds.writer_endpoint
}

output "aurora_readers" {
  description = "Reader endpoints Aurora"
  value       = module.rds.reader_endpoints
}

# Monitoring

output "monitoring_namespace" {
  description = "Namespace моніторингу"
  value       = module.monitoring.namespace
}

output "prometheus_service" {
  description = "Назва сервісу Prometheus"
  value       = module.monitoring.prometheus_service_name
}

output "grafana_service" {
  description = "Назва сервісу Grafana"
  value       = module.monitoring.grafana_service_name
}

output "alertmanager_service" {
  description = "Назва сервісу Alertmanager"
  value       = module.monitoring.alertmanager_service_name
}
