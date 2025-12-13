#------------------------------------------------------------------------------
# ECS Module - Variables
#------------------------------------------------------------------------------

variable "env_name" {
  description = "Environment name (e.g., prod, staging)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "ecs_sg_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

variable "target_group_cloud_arn" {
  description = "ALB target group ARN for Cloud (Fargate) service"
  type        = string
}

variable "execution_role_arn" {
  description = "ECS task execution role ARN"
  type        = string
}

variable "task_role_arn" {
  description = "ECS task role ARN"
  type        = string
}

variable "container_image" {
  description = "Container image URI (ECR)"
  type        = string
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 3000
}

variable "container_cpu" {
  description = "CPU units for container (256 = 0.25 vCPU)"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Memory for container in MB"
  type        = number
  default     = 512
}

variable "cloud_desired_count" {
  description = "Desired number of Cloud (Fargate) ECS tasks"
  type        = number
  default     = 2
}

variable "onprem_desired_count" {
  description = "Desired number of OnPrem (External) ECS tasks. Set to 0 until ECS Anywhere instance is registered."
  type        = number
  default     = 0
}

variable "onprem_vault_ip" {
  description = "On-premise Vault server IP"
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "enable_container_insights" {
  description = "Enable Container Insights for ECS cluster"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway (affects assign_public_ip for ECS tasks)"
  type        = bool
  default     = true
}

variable "ecs_cloud_max_count" {
  description = "Maximum number of Cloud (Fargate) ECS tasks for Auto Scaling"
  type        = number
  default     = 10
}

variable "ecs_cloud_target_cpu" {
  description = "Target CPU utilization for Cloud ECS Auto Scaling (%)"
  type        = number
  default     = 70
}

variable "vault_role_id" {
  description = "Vault AppRole Role ID"
  type        = string
  sensitive   = true
}

variable "vault_secret_id" {
  description = "Vault AppRole Secret ID"
  type        = string
  sensitive   = true
}
