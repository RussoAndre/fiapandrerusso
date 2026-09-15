# ──────────────────────────────────────────────────────────────────────────────
# terraform.tfvars — non-secret configuration values
# DO NOT commit db_password here. Set it via environment variable:
#   export TF_VAR_db_password="YourStrongPassword123!"
# ──────────────────────────────────────────────────────────────────────────────

aws_region   = "us-east-1"
project      = "togglemaster"
cluster_name = "togglemaster-cluster"

vpc_cidr = "10.0.0.0/16"

public_subnets = {
  "us-east-1a" = "10.0.1.0/24"
  "us-east-1b" = "10.0.2.0/24"
}

private_subnets = {
  "us-east-1a" = "10.0.10.0/24"
  "us-east-1b" = "10.0.11.0/24"
}

node_instance_types = ["t3.medium"]
node_desired_size   = 2
node_min_size       = 1
node_max_size       = 3
