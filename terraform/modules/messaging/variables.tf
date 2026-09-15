variable "project" {
  description = "Project name prefix used in resource names."
  type        = string
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}
