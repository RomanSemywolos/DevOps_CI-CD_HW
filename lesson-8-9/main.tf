module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = "lesson-7-hw-273497135368"
  table_name  = "terraform-locks"
}

module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  vpc_name           = "lesson-7-hw-vpc"
}

module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "lesson-7-hw-ecr"
  scan_on_push = true
}

provider "aws" {
  region = "eu-central-1"
}

module "eks" {
  source          = "./modules/eks"
  cluster_name    = "lesson-7-hw-cluster"
  subnet_ids      = module.vpc.public_subnets
  instance_type   = "t3.medium"
  desired_size    = 2
  min_size        = 2
  max_size        = 3
  node_group_name = "lesson7-node-group"
  vpc_id          = module.vpc.vpc_id
}

# Дані про кластер — через ім'я з модуля, а не var
data "aws_eks_cluster" "eks" {
  name = module.eks.eks_cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.eks_cluster_name
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

module "jenkins" {
  source       = "./modules/jenkins"
  cluster_name = module.eks.eks_cluster_name

  providers = {
    helm = helm
  }
}

module "argo_cd" {
  source        = "./modules/argo_cd"
  namespace     = "argocd"
  chart_version = "5.46.4"
}

module "rds" {
  source = "./modules/rds"

  name           = "django-db"
  use_aurora     = true
  aurora_replica_count = 1

  # Aurora
  engine_cluster             = "aurora-postgresql"
  engine_version_cluster     = "15.3"
  parameter_group_family_aurora = "aurora-postgresql15"

  # RDS (якщо захочеш переключитися use_aurora = false)
  engine                     = "postgres"
  engine_version             = "17.2"
  parameter_group_family_rds = "postgres17"

  # Common
  instance_class        = "db.t3.medium"
  allocated_storage     = 20
  db_name               = "djangoapp"
  username              = "postgres"
  password              = "pass2315wd"

  subnet_private_ids    = module.vpc.private_subnets
  subnet_public_ids     = module.vpc.public_subnets
  publicly_accessible   = false
  vpc_id                = module.vpc.vpc_id
  multi_az              = true
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
