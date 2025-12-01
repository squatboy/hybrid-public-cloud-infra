#------------------------------------------------------------------------------
# EKS Module - Variables
#------------------------------------------------------------------------------

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.30"
}

variable "cluster_role_arn" {
  description = "ARN of the IAM role for the EKS cluster"
  type        = string
}

variable "fargate_role_arn" {
  description = "ARN of the IAM role for Fargate pod execution"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EKS"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for EKS cluster"
  type        = list(string)
  default     = []
}

variable "endpoint_public_access" {
  description = "Enable public access to EKS API endpoint"
  type        = bool
  default     = true
}

variable "enabled_log_types" {
  description = "List of EKS cluster log types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator"]
}

variable "fargate_namespaces" {
  description = "List of additional namespaces for Fargate profile"
  type        = list(string)
  default     = ["staging", "production", "monitoring"]
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
