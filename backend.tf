terraform {
  backend "s3" {
    bucket         = "lesson-5-2734-9713-5368"    # S3 bucket
    key            = "lesson-5/terraform.tfstate" # Path in S3 for the state file
    region         = "eu-central-1"               # AWS region
    dynamodb_table = "terraform-locks"            # DynamoDB table for state locking
    encrypt        = true                         # Enable encryption
  }
}
