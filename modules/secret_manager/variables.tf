#------------------------------------------------------------------------------
# Secrets Manager Module - Variables
#------------------------------------------------------------------------------

variable "env_name" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "db_password" {
  description = "Master password for the RDS cluster"
  type        = string
  sensitive   = true
}

variable "db_host" {
  description = "RDS cluster endpoint"
  type        = string
}

variable "db_port" {
  description = "RDS cluster port"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "master_username" {
  description = "Master username"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
