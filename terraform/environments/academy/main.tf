# ──────────────────────────────────────────────────────────────────────────────
# Root module: AWS Academy environment
# Wires all child modules together.
# ──────────────────────────────────────────────────────────────────────────────

# ── Data source: look up the existing LabRole (AWS Academy restriction) ───────
data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

# ── Networking ────────────────────────────────────────────────────────────────
module "networking" {
  source = "../../modules/networking"

  project      = var.project
  cluster_name = var.cluster_name
  vpc_cidr     = var.vpc_cidr

  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  tags = local.common_tags
}

# ── EKS ───────────────────────────────────────────────────────────────────────
module "eks" {
  source = "../../modules/eks"

  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version

  # AWS Academy: reuse LabRole for both control-plane and worker nodes.
  cluster_role_arn = data.aws_iam_role.lab_role.arn
  node_role_arn    = data.aws_iam_role.lab_role.arn

  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids

  instance_types = var.node_instance_types
  desired_size   = var.node_desired_size
  min_size       = var.node_min_size
  max_size       = var.node_max_size

  tags = local.common_tags
}

# ── Databases ─────────────────────────────────────────────────────────────────
module "databases" {
  source = "../../modules/databases"

  project            = var.project
  vpc_id             = module.networking.vpc_id
  vpc_cidr           = var.vpc_cidr
  private_subnet_ids = module.networking.private_subnet_ids

  db_username = var.db_username
  db_password = var.db_password

  tags = local.common_tags
}

# ── Messaging ─────────────────────────────────────────────────────────────────
module "messaging" {
  source  = "../../modules/messaging"
  project = var.project
  tags    = local.common_tags
}

# ── ECR ───────────────────────────────────────────────────────────────────────
module "ecr" {
  source  = "../../modules/ecr"
  project = var.project
  tags    = local.common_tags
}
