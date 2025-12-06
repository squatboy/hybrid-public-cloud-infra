#------------------------------------------------------------------------------
# IAM Module - Variables
#------------------------------------------------------------------------------

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "github_repo" {
  description = "GitHub Repository name (format: org/repo) for OIDC trust"
  type        = string
}
