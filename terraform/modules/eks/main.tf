# ──────────────────────────────────────────────────────────────────────────────
# Module: eks
# Provisions: EKS Cluster + Managed Node Group
# AWS Academy: uses a pre-existing LabRole ARN (no IAM creation).
# ──────────────────────────────────────────────────────────────────────────────

# ── EKS Cluster ───────────────────────────────────────────────────────────────
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = concat(var.public_subnet_ids, var.private_subnet_ids)
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  # Encrypt secrets at rest using the default AWS-managed key.
  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = var.kms_key_arn != "" ? var.kms_key_arn : null
    }
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator"]

  tags = merge(var.tags, { Name = var.cluster_name })

  lifecycle {
    ignore_changes = [encryption_config]
  }
}

# ── Node Group ────────────────────────────────────────────────────────────────
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-nodes"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  ami_type       = "AL2_x86_64"
  instance_types = var.instance_types
  capacity_type  = "ON_DEMAND"

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }

  update_config {
    max_unavailable = 1
  }

  tags = merge(var.tags, { Name = "${var.cluster_name}-node-group" })
}

# ── aws-auth ConfigMap (grants node role access to the cluster) ───────────────
resource "aws_eks_access_entry" "nodes" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.node_role_arn
  type          = "EC2_LINUX"
}
