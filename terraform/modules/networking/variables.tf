variable "project" {
  description = "Project name prefix used in resource names and tags."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name (used for subnet tagging)."
  type        = string
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

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}
