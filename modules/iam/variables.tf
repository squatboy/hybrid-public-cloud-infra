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
