#------------------------------------------------------------------------------
# Root Module - Variables
# 전역 변수 정의 (모든 모듈에서 공통으로 사용)
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Test (Disable Nat Gateway) Setting
#------------------------------------------------------------------------------

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for Private Subnets (Set false for cost saving in Test)"
  type        = bool
  default     = true
}

#------------------------------------------------------------------------------
# General Settings
#------------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS Region for resources"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., prod, staging, dev)"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming and tagging"
  type        = string
}

#------------------------------------------------------------------------------
# Network Settings
#------------------------------------------------------------------------------

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks (Multi-AZ)"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks (Multi-AZ)"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
}

#------------------------------------------------------------------------------
# VPN Settings (On-Premise Connection)
#------------------------------------------------------------------------------

variable "onprem_public_ip" {
  description = "On-premise NAT Gateway public IP address"
  type        = string

  validation {
    condition     = can(regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$", var.onprem_public_ip))
    error_message = "On-premise public IP must be a valid IPv4 address."
  }
}

variable "onprem_cidr" {
  description = "On-premise internal network CIDR block"
  type        = string

  validation {
    condition     = can(cidrhost(var.onprem_cidr, 0))
    error_message = "On-premise CIDR must be a valid IPv4 CIDR block."
  }
}

variable "bgp_asn" {
  description = "BGP Autonomous System Number for Customer Gateway"
  type        = number

  validation {
    condition     = var.bgp_asn >= 64512 && var.bgp_asn <= 65534
    error_message = "BGP ASN must be in the private ASN range (64512-65534)."
  }
}

#------------------------------------------------------------------------------
# Common Tags
#------------------------------------------------------------------------------

variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

#------------------------------------------------------------------------------
# ECS Settings
#------------------------------------------------------------------------------

variable "ecs_container_port" {
  description = "Container port for ECS service"
  type        = number
}

variable "ecs_container_cpu" {
  description = "CPU units for ECS task (256 = 0.25 vCPU)"
  type        = number
}

variable "ecs_container_memory" {
  description = "Memory for ECS task in MB"
  type        = number
}

variable "ecs_cloud_desired_count" {
  description = "Desired number of Cloud (Fargate) ECS tasks"
  type        = number
  default     = 1
}

variable "ecs_onprem_desired_count" {
  description = "Desired number of OnPrem (External) ECS tasks. Set to 0 until ECS Anywhere instance is registered."
  type        = number
  default     = 0
}

variable "onprem_vault_ip" {
  description = "On-premise Vault server IP address"
  type        = string
}

variable "onprem_server_ip" {
  description = "On-premise application server IP address (vm-app-01) for ALB Target Group"
  type        = string
  default     = "10.10.10.20"
}

#------------------------------------------------------------------------------
# ECR Settings
#------------------------------------------------------------------------------

variable "ecr_repository_names" {
  description = "List of ECR repository names"
  type        = list(string)
}

#------------------------------------------------------------------------------
# RDS Settings (Aurora Serverless v2)
#------------------------------------------------------------------------------

variable "db_master_password" {
  description = "Master password for Aurora database"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Name of the default database"
  type        = string
}

variable "db_min_capacity" {
  description = "Minimum ACU for Aurora Serverless v2"
  type        = number
}

variable "db_max_capacity" {
  description = "Maximum ACU for Aurora Serverless v2"
  type        = number
}

#------------------------------------------------------------------------------
# Locals - Computed Values
#------------------------------------------------------------------------------

locals {
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.additional_tags
  )
}

