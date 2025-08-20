#!/bin/bash
# Auto-create S3 bucket and DynamoDB table if missing, then configure Terraform backend.

BUCKET_NAME="lesson-5-2734-9713-5368"
DYNAMO_TABLE="terraform-locks"
REGION="eu-central-1"

echo "Checking if S3 bucket exists..."
aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null || {
    echo "Bucket does not exist. Creating..."
    aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION" --create-bucket-configuration LocationConstraint=$REGION
    aws s3api put-bucket-versioning --bucket "$BUCKET_NAME" --versioning-configuration Status=Enabled
    echo "S3 bucket created and versioning enabled."
}

echo "Checking if DynamoDB table exists..."
aws dynamodb describe-table --table-name "$DYNAMO_TABLE" 2>/dev/null || {
    echo "DynamoDB table does not exist. Creating..."
    aws dynamodb create-table \
        --table-name "$DYNAMO_TABLE" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST
    echo "Waiting for table to become active..."
    aws dynamodb wait table-exists --table-name "$DYNAMO_TABLE"
    echo "DynamoDB table is ready."
}

echo "Configuring Terraform backend..."
cat > backend.tf <<EOL
terraform {
  backend "s3" {
    bucket         = "$BUCKET_NAME"
    key            = "lesson-5/terraform.tfstate"
    region         = "$REGION"
    dynamodb_table = "$DYNAMO_TABLE"
    encrypt        = true
  }
}
EOL

echo "Backend configured. You can now run 'terraform init'."
