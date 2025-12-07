#------------------------------------------------------------------------------
# RDS Module - Variables
#------------------------------------------------------------------------------

variable "env_name" {
  description = "Environment name for resource naming"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for Aurora"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for Aurora"
  type        = list(string)
}

#------------------------------------------------------------------------------
# Database Configuration
#------------------------------------------------------------------------------

variable "engine_version" {
  description = "Aurora MySQL engine version (3.08.0+ required for 0 ACU support)"
  type        = string
  default     = "8.0.mysql_aurora.3.08.0"
}

variable "database_name" {
  description = "Name of the default database"
  type        = string
  default     = "app_db"
}

variable "master_username" {
  description = "Master username for the database"
  type        = string
  default     = "admin"
}

variable "master_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
}

#------------------------------------------------------------------------------
# Serverless v2 Scaling
#------------------------------------------------------------------------------

variable "min_capacity" {
  description = "Minimum ACU capacity for Serverless v2 (0 enables auto-pause)"
  type        = number
  default     = 0
}

variable "max_capacity" {
  description = "Maximum ACU capacity for Serverless v2"
  type        = number
  default     = 1.0
}

variable "seconds_until_auto_pause" {
  description = "Seconds of inactivity before auto-pause (300-86400, only applies when min_capacity=0)"
  type        = number
  default     = 300 # 5 minutes
}

variable "instance_count" {
  description = "Number of Aurora instances"
  type        = number
  default     = 1
}

#------------------------------------------------------------------------------
# Backup and Protection
#------------------------------------------------------------------------------

variable "backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "Preferred backup window (UTC)"
  type        = string
  default     = "03:00-04:00"
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
