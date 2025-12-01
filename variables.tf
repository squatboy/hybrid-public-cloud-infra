#------------------------------------------------------------------------------
# Root Module - Variables
# 전역 변수 정의 (모든 모듈에서 공통으로 사용)
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# General Settings
#------------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS Region for resources"
  type        = string
  default     = "ap-northeast-2"
}

variable "environment" {
  description = "Environment name (e.g., prod, staging, dev)"
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "Project name for resource naming and tagging"
  type        = string
  default     = "pii-hybrid"
}

#------------------------------------------------------------------------------
# Network Settings
#------------------------------------------------------------------------------

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.20.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks (Multi-AZ)"
  type        = list(string)
  default     = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks (Multi-AZ)"
  type        = list(string)
  default     = ["10.20.10.0/24", "10.20.11.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
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
  default     = "10.10.10.0/24"

  validation {
    condition     = can(cidrhost(var.onprem_cidr, 0))
    error_message = "On-premise CIDR must be a valid IPv4 CIDR block."
  }
}

variable "bgp_asn" {
  description = "BGP Autonomous System Number for Customer Gateway"
  type        = number
  default     = 65000

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
# EKS Settings
#------------------------------------------------------------------------------

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "hybrid-pii-cluster"
}

variable "eks_cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.30"
}

variable "fargate_namespaces" {
  description = "List of namespaces for Fargate profile"
  type        = list(string)
  default     = ["staging", "production", "monitoring"]
}

#------------------------------------------------------------------------------
# ECR Settings
#------------------------------------------------------------------------------

variable "ecr_repository_names" {
  description = "List of ECR repository names"
  type        = list(string)
  default     = ["pii-system/pii-api"]
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
  default     = "app_db"
}

variable "db_min_capacity" {
  description = "Minimum ACU for Aurora Serverless v2"
  type        = number
  default     = 0.5
}

variable "db_max_capacity" {
  description = "Maximum ACU for Aurora Serverless v2"
  type        = number
  default     = 1.0
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

