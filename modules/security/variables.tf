#------------------------------------------------------------------------------
# Security Module - Variables
#------------------------------------------------------------------------------

variable "env_name" {
  description = "Environment name (e.g., prod, staging)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block for internal communication rules"
  type        = string
}

variable "onprem_cidr" {
  description = "On-premise network CIDR block"
  type        = string
}

variable "allow_vpc_cidr" {
  description = "Whether to allow all traffic from VPC CIDR"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
