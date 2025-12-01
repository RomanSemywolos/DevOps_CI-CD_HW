output "s3_bucket_id" {
  description = "ID of the S3 bucket used for Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table used for Terraform locks"
  value       = aws_dynamodb_table.terraform_locks.name
}
