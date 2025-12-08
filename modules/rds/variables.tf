#------------------------------------------------------------------------------
# RDS Module - Variables
#------------------------------------------------------------------------------

variable "env_name" {
  description = "Environment name for resource naming"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for RDS"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for RDS"
  type        = list(string)
}

#------------------------------------------------------------------------------
# Database Configuration
#------------------------------------------------------------------------------

variable "engine_version" {
  description = "MySQL engine version"
  type        = string
  default     = "8.0"
}

variable "instance_class" {
  description = "RDS instance class (db.t3.micro for Free Tier)"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB (Free Tier: 20GB)"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum allocated storage in GB for autoscaling"
  type        = number
  default     = 20
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
# Backup and Protection
#------------------------------------------------------------------------------

variable "backup_retention_period" {
  description = "Number of days to retain backups (Free Tier: max 1 day)"
  type        = number
  default     = 1
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
