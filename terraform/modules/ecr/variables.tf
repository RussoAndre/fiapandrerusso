variable "project" {
  description = "Project name used as ECR namespace prefix."
  type        = string
}

variable "services" {
  description = "List of microservice names — one ECR repository will be created per entry."
  type        = list(string)
  default     = ["auth", "flag", "targeting", "evaluation", "analytics"]
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}
