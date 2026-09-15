# ──────────────────────────────────────────────────────────────────────────────
# Remote Backend: S3 + optional state locking
#
# Before running `terraform init`:
#   1. Create the S3 bucket manually (or with a bootstrap script):
#      aws s3api create-bucket --bucket togglemaster-tfstate-<YOUR_ACCOUNT_ID> \
#        --region us-east-1
#      aws s3api put-bucket-versioning --bucket togglemaster-tfstate-<ACCOUNT> \
#        --versioning-configuration Status=Enabled
#   2. Replace <YOUR_ACCOUNT_ID> below.
# ──────────────────────────────────────────────────────────────────────────────

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "togglemaster-tfstate-REPLACE_ACCOUNT_ID"
    key            = "academy/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile   = true   # native S3 locking (Terraform >= 1.10) — no DynamoDB needed
  }
}

provider "aws" {
  region = var.aws_region
}
