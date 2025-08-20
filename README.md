# lesson-5: Terraform Infrastructure on AWS

## Project Structure

```
lesson-5/
│
├── main.tf          # Main file to connect all modules
├── backend.tf       # Terraform backend configuration (S3 + DynamoDB)
├── outputs.tf       # Global outputs from all modules
│
├── modules/         # Directory containing reusable modules
│ │
│ ├── s3-backend/    # Module for S3 bucket and DynamoDB table
│ │ ├── s3.tf
│ │ ├── dynamodb.tf
│ │ ├── variables.tf
│ │ └── outputs.tf
│ │
│ ├── vpc/           # Module for VPC infrastructure
│ │ ├── vpc.tf
│ │ ├── routes.tf
│ │ ├── variables.tf
│ │ └── outputs.tf
│ │
│ └── ecr/           # Module for ECR repository
│   ├── ecr.tf
│   ├── variables.tf
│   └── outputs.tf
│
└── README.md        # Project documentation
```

---

## Terraform Commands

1. **Initialize Terraform (downloads providers, sets up modules)**

```bash
terraform init
```

2. **Preview infrastructure changes**

```bash
terraform plan
```

3. **Apply changes, create resources**

```bash
terraform apply
```

4. **Destroy all created resources**

```bash
terraform destroy
```

5. **View outputs**

```bash
terraform output
```

---

## Modules Overview

### Module: s3-backend

Manages Terraform state storage:

- **aws_s3_bucket** – bucket with versioning and encryption enabled.
- **aws_dynamodb_table** – table for locking state files to prevent concurrent updates.
- Automatically used in `backend.tf` for state management.

### Module: vpc

Sets up basic networking:

- **aws_vpc** – main network with configurable CIDR block.
- **aws_subnet** – 3 public and 3 private subnets across availability zones.
- **aws_internet_gateway** – public subnets can access the internet.
- **aws_nat_gateway** – private subnets can access the internet.
- **aws_route_table, aws_route, aws_route_table_association** – traffic routing.

### Module: ecr

Creates an ECR repository for Docker images:

- **aws_ecr_repository** – optional image scanning (`scan_on_push = true`).
- **aws_ecr_repository_policy** – allows EC2 (or other AWS services) to pull images.
- Default policy grants pull access to `ec2.amazonaws.com`.

---

## Backend Automation Script

To fully automate backend creation without manual edits, use the included shell script for Linux:

**File:** `setup-backend.sh`

```bash
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
```

**Usage:**

```bash
chmod +x setup-backend.sh
./setup-backend.sh
terraform init
```

This approach avoids any manual editing of `backend.tf` and ensures that Terraform can automatically use S3 + DynamoDB as the backend.

---

## Notes

- Make sure your AWS credentials have permissions for **S3, DynamoDB, VPC, ECR, EC2, Elastic IPs, Internet Gateway, NAT Gateway**.
- The bucket name in `setup-backend.sh` should be globally unique.
- Outputs of Terraform include:
  - `s3_bucket_name` – S3 bucket for state files
  - `dynamodb_table_name` – DynamoDB lock table
  - `vpc_id` – main VPC ID
  - `public_subnets`, `private_subnets`
  - `ecr_repository_url` – ECR repository URL

