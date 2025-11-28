#------------------------------------------------------------------------------
# VPN Module - Variables
#------------------------------------------------------------------------------

variable "env_name" {
  description = "Environment name (e.g., prod, staging)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where VPN Gateway will be attached"
  type        = string
}

variable "onprem_public_ip" {
  description = "On-premise NAT Gateway public IP address"
  type        = string
}

variable "onprem_cidr" {
  description = "On-premise internal network CIDR block"
  type        = string
}

variable "route_table_id" {
  description = "Route table ID for VPN route propagation"
  type        = string
}

variable "bgp_asn" {
  description = "BGP Autonomous System Number for Customer Gateway"
  type        = number
  default     = 65000
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
