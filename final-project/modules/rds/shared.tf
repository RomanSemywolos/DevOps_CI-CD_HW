# DB Subnet group (спільний для RDS і Aurora)
resource "aws_db_subnet_group" "default" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.publicly_accessible ? var.subnet_public_ids : var.subnet_private_ids

  tags = merge(var.tags, {
    Name = "${var.name}-subnet-group"
  })
}

# Security Group для доступу до бази
resource "aws_security_group" "rds" {
  name        = "${var.name}-sg"
  description = "Security group for RDS / Aurora access"
  vpc_id      = var.vpc_id

  # Доступ ТІЛЬКИ з SG нод EKS
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.node_sg_id]
  }

  # Вихід куди завгодно (наприклад, до інтернету для оновлень)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-sg"
  })
}
