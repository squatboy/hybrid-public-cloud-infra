#------------------------------------------------------------------------------
# ALB Module - Variables
#------------------------------------------------------------------------------

variable "env_name" {
  description = "Environment name (e.g., prod, staging)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "alb_sg_id" {
  description = "Security group ID for ALB"
  type        = string
}

variable "container_port" {
  description = "Container port for target group"
  type        = number
  default     = 3000
}

variable "health_check_path" {
  description = "Health check path for target group"
  type        = string
  default     = "/health"
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for ALB"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
