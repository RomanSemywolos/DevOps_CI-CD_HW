terraform {
  backend "s3" {
    bucket         = "lesson-5-2734-9713-5368"
    key            = "lesson-8-9/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
