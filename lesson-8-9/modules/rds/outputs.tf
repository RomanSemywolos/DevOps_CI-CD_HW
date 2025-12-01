output "endpoint" {
  description = "DNS endpoint бази даних (Aurora або стандартна RDS)"
  value = var.use_aurora ?
    aws_rds_cluster.aurora[0].endpoint :
    aws_db_instance.standard[0].address
}

output "writer_endpoint" {
  description = "Writer endpoint (тільки для Aurora)"
  value = var.use_aurora ?
    aws_rds_cluster.aurora[0].endpoint :
    ""
}

output "reader_endpoints" {
  description = "Список reader endpoint'ів (тільки Aurora)"
  value = var.use_aurora ?
    aws_rds_cluster_instance.readers[*].endpoint :
    []
}
