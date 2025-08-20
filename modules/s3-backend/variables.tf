variable "bucket_name" {
  description = "Name of the S3 bucket for storing Terraform state"
  type        = string
}

variable "table_name" {
  description = "Name of the DynamoDB table for Terraform state locks"
  type        = string
}
