#------------------------------------------------------------------------------
# SSM Module - Variables
#------------------------------------------------------------------------------

variable "env_name" {
  description = "Environment name (e.g., prod, staging)"
  type        = string
}

variable "ssm_role_name" {
  description = "Name of the IAM role for SSM managed instances"
  type        = string
}

variable "registration_limit" {
  description = "Maximum number of managed instances that can be registered"
  type        = number
  default     = 5
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
