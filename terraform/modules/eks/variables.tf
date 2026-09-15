variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.29"
}

# AWS Academy: pass the LabRole ARN here instead of creating a new role.
variable "cluster_role_arn" {
  description = "IAM role ARN for the EKS control plane (use LabRole on AWS Academy)."
  type        = string
}

variable "node_role_arn" {
  description = "IAM role ARN for EKS worker nodes (use LabRole on AWS Academy)."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for secrets encryption. Leave empty to skip."
  type        = string
  default     = ""
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the cluster VPC config."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for node groups."
  type        = list(string)
}

variable "instance_types" {
  description = "EC2 instance types for the node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "desired_size" {
  description = "Desired number of worker nodes."
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of worker nodes."
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of worker nodes."
  type        = number
  default     = 3
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}
