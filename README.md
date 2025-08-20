lesson-5/

│

├── main.tf # Main file to connect all modules

├── backend.tf # Terraform backend configuration (S3 + DynamoDB)

├── outputs.tf # Global outputs from all modules

│

├── modules/ # Directory containing reusable modules

│ │

│ ├── s3-backend/ # Module for S3 bucket and DynamoDB table

│ │ ├── s3.tf

│ │ ├── dynamodb.tf

│ │ ├── variables.tf

│ │ └── outputs.tf

│ │

│ ├── vpc/ # Module for VPC infrastructure

│ │ ├── vpc.tf

│ │ ├── routes.tf

│ │ ├── variables.tf

│ │ └── outputs.tf

│ │

│ └── ecr/ # Module for ECR repository

│ ├── ecr.tf

│ ├── variables.tf

│ └── outputs.tf

│

└── README.md # Project documentation





---



\## Terraform Commands



1\. \*\*Initialize Terraform (downloads providers, sets up modules)\*\*



```bash

terraform init





Preview infrastructure changes



terraform plan





Apply changes, create resources



terraform apply





Destroy all created resources



terraform destroy





View outputs



terraform output



Modules Overview

Module: s3-backend



Manages Terraform state storage:



aws\_s3\_bucket – bucket with versioning and encryption enabled.



aws\_dynamodb\_table – table for locking state files to prevent concurrent updates.



Automatically used in backend.tf for state management.



Module: vpc



Sets up basic networking:



aws\_vpc – main network with configurable CIDR block.



aws\_subnet – 3 public and 3 private subnets across availability zones.



aws\_internet\_gateway – public subnets can access the internet.



aws\_nat\_gateway – private subnets can access the internet.



aws\_route\_table, aws\_route, aws\_route\_table\_association – traffic routing.



Module: ecr



Creates an ECR repository for Docker images:



aws\_ecr\_repository – optional image scanning (scan\_on\_push = true).



aws\_ecr\_repository\_policy – allows EC2 (or other AWS services) to pull images.



Default policy grants pull access to ec2.amazonaws.com.



Backend Automation Script



To fully automate backend creation without manual edits, use the included shell script for Linux:



File: setup-backend.sh



\#!/bin/bash

\# Auto-create S3 bucket and DynamoDB table if missing, then configure Terraform backend.



BUCKET\_NAME="lesson-5-2734-9713-5368"

DYNAMO\_TABLE="terraform-locks"

REGION="eu-central-1"



echo "Checking if S3 bucket exists..."

aws s3api head-bucket --bucket "$BUCKET\_NAME" 2>/dev/null || {

&nbsp;   echo "Bucket does not exist. Creating..."

&nbsp;   aws s3api create-bucket --bucket "$BUCKET\_NAME" --region "$REGION" --create-bucket-configuration LocationConstraint=$REGION

&nbsp;   aws s3api put-bucket-versioning --bucket "$BUCKET\_NAME" --versioning-configuration Status=Enabled

&nbsp;   echo "S3 bucket created and versioning enabled."

}



echo "Checking if DynamoDB table exists..."

aws dynamodb describe-table --table-name "$DYNAMO\_TABLE" 2>/dev/null || {

&nbsp;   echo "DynamoDB table does not exist. Creating..."

&nbsp;   aws dynamodb create-table \\

&nbsp;       --table-name "$DYNAMO\_TABLE" \\

&nbsp;       --attribute-definitions AttributeName=LockID,AttributeType=S \\

&nbsp;       --key-schema AttributeName=LockID,KeyType=HASH \\

&nbsp;       --billing-mode PAY\_PER\_REQUEST

&nbsp;   echo "Waiting for table to become active..."

&nbsp;   aws dynamodb wait table-exists --table-name "$DYNAMO\_TABLE"

&nbsp;   echo "DynamoDB table is ready."

}



echo "Configuring Terraform backend..."

cat > backend.tf <<EOL

terraform {

&nbsp; backend "s3" {

&nbsp;   bucket         = "$BUCKET\_NAME"

&nbsp;   key            = "lesson-5/terraform.tfstate"

&nbsp;   region         = "$REGION"

&nbsp;   dynamodb\_table = "$DYNAMO\_TABLE"

&nbsp;   encrypt        = true

&nbsp; }

}

EOL



echo "Backend configured. You can now run 'terraform init'."





Usage:



chmod +x setup-backend.sh

./setup-backend.sh

terraform init





This approach avoids any manual editing of backend.tf and ensures that Terraform can automatically use S3 + DynamoDB as the backend.



Notes



Make sure your AWS credentials have permissions for S3, DynamoDB, VPC, ECR, EC2, Elastic IPs, Internet Gateway, NAT Gateway.



The bucket name in setup-backend.sh should be globally unique.



Outputs of Terraform include:



s3\_bucket\_name – S3 bucket for state files



dynamodb\_table\_name – DynamoDB lock table



vpc\_id – main VPC ID



public\_subnets, private\_subnets



ecr\_repository\_url – ECR repository URL

