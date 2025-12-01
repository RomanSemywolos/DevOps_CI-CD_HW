output "s3_bucket_name" {
  description = "Назва S3-бакета для стейтів"
  value       = module.s3_backend.s3_bucket_name
}

output "dynamodb_table_name" {
  description = "Назва таблиці DynamoDB для блокування стейтів"
  value       = module.s3_backend.dynamodb_table_name
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnet_ids
}

output "private_subnets" {
  value = module.vpc.private_subnet_ids
}

output "internet_gateway_id" {
  value = module.vpc.internet_gateway_id
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "eks_cluster_endpoint" {
  description = "EKS API endpoint для підключення до кластера"
  value       = module.eks.eks_cluster_endpoint
}

output "eks_cluster_name" {
  description = "Назва EKS кластера"
  value       = module.eks.eks_cluster_name
}

output "eks_node_role_arn" {
  description = "IAM role ARN для worker-нoд"
  value       = module.eks.eks_node_role_arn
}

output "jenkins_release" {
  value = module.jenkins.jenkins_release_name
}

output "jenkins_namespace" {
  value = module.jenkins.jenkins_namespace
}

# RDS outputs
output "rds_endpoint" {
  description = "Endpoint бази даних (для Django POSTGRES_HOST)"
  value       = module.rds.endpoint
}

output "rds_writer_endpoint" {
  description = "Writer endpoint (Aurora only)"
  value       = module.rds.writer_endpoint
}

output "rds_reader_endpoints" {
  description = "Reader endpoints (Aurora only)"
  value       = module.rds.reader_endpoints
}
