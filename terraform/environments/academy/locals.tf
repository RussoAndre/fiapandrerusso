locals {
  common_tags = {
    Project     = var.project
    Environment = "academy"
    ManagedBy   = "terraform"
  }
}
