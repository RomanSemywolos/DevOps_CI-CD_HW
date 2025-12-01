provider "aws" {
  region = "eu-central-1"
}

# S3 + DynamoDB backend (той самий bucket/table, що й у lesson-5)
module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = "lesson-5-2734-9713-5368"
  table_name  = "terraform-locks"
}

# VPC – структура як у lesson-5, але для lesson-7
module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  vpc_name           = "lesson-7-vpc"
}

# ECR – назва з першого завдання
module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "lesson-5-ecr"
  scan_on_push = true
}

# EKS – працює в тій же VPC (публічні сабнети з модулю vpc)
module "eks" {
  source        = "./modules/eks"
  cluster_name  = "lesson-7-eks-cluster"
  subnet_ids    = module.vpc.public_subnet_ids
  instance_type = "t2.medium"

  desired_size = 2
  min_size     = 2
  max_size     = 2
}
