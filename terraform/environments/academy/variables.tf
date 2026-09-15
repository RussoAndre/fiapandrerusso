variable "aws_region" {
  description = "AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project identifier used in resource names."
  type        = string
  default     = "togglemaster"
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
  default     = "togglemaster-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS."
  type        = string
  default     = "1.29"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Map of AZ => CIDR for public subnets."
  type        = map(string)
  default = {
    "us-east-1a" = "10.0.1.0/24"
    "us-east-1b" = "10.0.2.0/24"
  }
}

variable "private_subnets" {
  description = "Map of AZ => CIDR for private subnets."
  type        = map(string)
  default = {
    "us-east-1a" = "10.0.10.0/24"
    "us-east-1b" = "10.0.11.0/24"
  }
}

variable "node_instance_types" {
  description = "EC2 instance types for EKS worker nodes."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired number of worker nodes."
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes."
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes."
  type        = number
  default     = 3
}

variable "db_username" {
  description = "Master username for all RDS instances."
  type        = string
  default     = "togglemaster"
  sensitive   = true
}

variable "db_password" {
  description = "Master password for all RDS instances. Set via TF_VAR_db_password."
  type        = string
  sensitive   = true
}
