# AWS provider

provider "aws" {
  region = "eu-central-1"
}

# S3 backend (bucket + dynamodb)

module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = "final-project-273497135368"
  table_name  = "terraform-locks"
}

# VPC

module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"

  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  availability_zones = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]

  vpc_name = "final-project-hw-vpc"
}

# ECR

module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "final-project-hw-ecr"
  scan_on_push = true
}

# EKS

module "eks" {
  source = "./modules/eks"

  cluster_name    = "final-project-hw-cluster"
  subnet_ids      = module.vpc.public_subnet_ids

  instance_type   = "t3.medium"
  desired_size    = 2
  min_size        = 2
  max_size        = 3
  node_group_name = "finalproject-node-group"

  vpc_id = module.vpc.vpc_id
}

# EKS auth

data "aws_eks_cluster" "eks" {
  name = module.eks.eks_cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.eks_cluster_name
}

# Helm provider (for EKS)

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

# Kubernetes provider (needed for monitoring!)

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

# Jenkins

module "jenkins" {
  source       = "./modules/jenkins"
  cluster_name = module.eks.eks_cluster_name

  providers = {
    helm = helm
  }
}

# Argo CD

module "argo_cd" {
  source        = "./modules/argo_cd"
  namespace     = "argocd"
  chart_version = "5.46.4"

  providers = {
    helm = helm
  }
}

# RDS / Aurora

module "rds" {
  source = "./modules/rds"

  name                 = "django-db"
  use_aurora           = true
  aurora_replica_count = 1

  engine_cluster             = "aurora-postgresql"
  engine_version_cluster     = "15.3"
  parameter_group_family_aurora = "aurora-postgresql15"

  engine                     = "postgres"
  engine_version             = "17.2"
  parameter_group_family_rds = "postgres17"

  instance_class          = "db.t3.medium"
  allocated_storage       = 20
  db_name                 = "djangoapp"
  username                = "postgres"
  password                = "pass2315wd"
  publicly_accessible     = false

  vpc_id                  = module.vpc.vpc_id
  subnet_private_ids      = module.vpc.private_subnet_ids
  subnet_public_ids       = module.vpc.public_subnet_ids
  multi_az                = true
  backup_retention_period = 7

  node_sg_id = module.eks.eks_nodes_sg_id

  parameters = {
    max_connections            = "200"
    log_min_duration_statement = "500"
  }

  tags = {
    Environment = "dev"
    Project     = "djangoapp"
  }
}

# Monitoring (Prometheus + Grafana)

module "monitoring" {
  source = "./modules/monitoring"

  namespace                 = "monitoring"
  prometheus_chart_version  = var.prometheus_chart_version

  grafana_admin_password    = var.grafana_admin_password

  prometheus_retention      = var.prometheus_retention
  prometheus_storage_size   = var.prometheus_storage_size
  grafana_storage_size      = var.grafana_storage_size
  alertmanager_storage_size = var.alertmanager_storage_size

  enable_alertmanager       = var.enable_alertmanager
  enable_node_exporter      = var.enable_node_exporter
  enable_kube_state_metrics = var.enable_kube_state_metrics

  slack_webhook_url = var.slack_webhook_url
  slack_channel     = var.slack_channel

  create_ingress        = var.create_monitoring_ingress
  grafana_hostname      = var.grafana_hostname
  prometheus_hostname   = var.prometheus_hostname
  alertmanager_hostname = var.alertmanager_hostname

  environment  = var.environment
  project_name = var.project_name

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }

  depends_on = [module.eks]
}

############################################
# Root variables (виніс би їх окремо, та не хочу ламати структуру)
############################################

variable "prometheus_chart_version" {
  type    = string
  default = "55.5.0"
}

variable "grafana_admin_password" {
  type      = string
  sensitive = true
  default   = "admin123"
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
  default   = ""
}

variable "slack_channel" {
  type    = string
  default = "#alerts"
}

variable "create_monitoring_ingress" {
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

variable "environment" {
  type    = string
  default = "dev"
}

variable "project_name" {
  type    = string
  default = "djangoapp"
}