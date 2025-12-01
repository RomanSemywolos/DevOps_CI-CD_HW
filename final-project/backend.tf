terraform {
  backend "s3" {
    bucket         = "final-project-273497135368"
    key            = "final-project/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
