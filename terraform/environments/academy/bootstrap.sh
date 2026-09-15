#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# bootstrap.sh — create the S3 bucket for Terraform remote state
# Run this ONCE before `terraform init`.
# Usage: ./bootstrap.sh <aws-account-id>
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

ACCOUNT_ID="${1:-}"
if [[ -z "${ACCOUNT_ID}" ]]; then
  ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
fi

BUCKET="togglemaster-tfstate-${ACCOUNT_ID}"
REGION="us-east-1"

echo "Creating S3 bucket: ${BUCKET} in ${REGION}"

aws s3api create-bucket \
  --bucket "${BUCKET}" \
  --region "${REGION}"

aws s3api put-bucket-versioning \
  --bucket "${BUCKET}" \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket "${BUCKET}" \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

aws s3api put-public-access-block \
  --bucket "${BUCKET}" \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

echo ""
echo "Done! Now update backend.tf replacing REPLACE_ACCOUNT_ID with: ${ACCOUNT_ID}"
echo "Then run: terraform init"
