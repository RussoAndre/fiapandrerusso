variable "project" {
  description = "Project name prefix."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where databases will be deployed."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block used for security group ingress rules."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for database placement."
  type        = list(string)
}

variable "rds_databases" {
  description = "List of RDS instance names to create (one instance per entry)."
  type        = list(string)
  default     = ["auth-db", "flag-db", "analytics-db"]
}

variable "db_username" {
  description = "Master username for RDS instances."
  type        = string
  default     = "togglemaster"
  sensitive   = true
}

variable "db_password" {
  description = "Master password for RDS instances. Provide via TF_VAR_db_password env var."
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}
