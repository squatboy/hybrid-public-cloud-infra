#------------------------------------------------------------------------------
# Root Module - Outputs
# 모듈에서 생성된 리소스 정보 출력
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# VPC Outputs
#------------------------------------------------------------------------------

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR Block"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "List of Public Subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of Private Subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_public_ip" {
  description = "NAT Gateway Public IP"
  value       = module.vpc.nat_gateway_public_ip
}

#------------------------------------------------------------------------------
# VPN Outputs (온프레미스 설정에 필요)
#------------------------------------------------------------------------------

output "vpn_connection_id" {
  description = "VPN Connection ID"
  value       = module.vpn.vpn_connection_id
}

output "customer_gateway_id" {
  description = "Customer Gateway ID"
  value       = module.vpn.customer_gateway_id
}

output "vpn_gateway_id" {
  description = "Virtual Private Gateway ID"
  value       = module.vpn.vpn_gateway_id
}

# Tunnel 1 정보
output "vpn_tunnel1_address" {
  description = "VPN Tunnel 1 - AWS Public IP (온프레미스에서 연결할 주소)"
  value       = module.vpn.tunnel1_address
}

output "vpn_tunnel1_cgw_inside_address" {
  description = "VPN Tunnel 1 - Customer Gateway Inside IP (온프레미스 터널 IP)"
  value       = module.vpn.tunnel1_cgw_inside_address
}

output "vpn_tunnel1_vgw_inside_address" {
  description = "VPN Tunnel 1 - VPN Gateway Inside IP (AWS 터널 IP)"
  value       = module.vpn.tunnel1_vgw_inside_address
}

output "vpn_tunnel1_preshared_key" {
  description = "VPN Tunnel 1 - Pre-Shared Key (PSK) ⚠️ 보안 주의"
  value       = module.vpn.tunnel1_preshared_key
  sensitive   = true
}

# Tunnel 2 정보 (고가용성용)
output "vpn_tunnel2_address" {
  description = "VPN Tunnel 2 - AWS Public IP (백업 터널)"
  value       = module.vpn.tunnel2_address
}

output "vpn_tunnel2_cgw_inside_address" {
  description = "VPN Tunnel 2 - Customer Gateway Inside IP"
  value       = module.vpn.tunnel2_cgw_inside_address
}

output "vpn_tunnel2_vgw_inside_address" {
  description = "VPN Tunnel 2 - VPN Gateway Inside IP"
  value       = module.vpn.tunnel2_vgw_inside_address
}

output "vpn_tunnel2_preshared_key" {
  description = "VPN Tunnel 2 - Pre-Shared Key (PSK) ⚠️ 보안 주의"
  value       = module.vpn.tunnel2_preshared_key
  sensitive   = true
}

#------------------------------------------------------------------------------
# Security Group Outputs
#------------------------------------------------------------------------------

output "vpn_access_sg_id" {
  description = "VPN Access Security Group ID"
  value       = module.security.vpn_sg_id
}

output "private_default_sg_id" {
  description = "Private Default Security Group ID"
  value       = module.security.private_default_sg_id
}

#------------------------------------------------------------------------------
# 온프레미스 VPN 설정용 요약 출력
#------------------------------------------------------------------------------

output "onprem_vpn_config_summary" {
  description = "온프레미스 VPN 설정에 필요한 정보 요약"
  value = {
    aws_tunnel1_public_ip    = module.vpn.tunnel1_address
    aws_tunnel2_public_ip    = module.vpn.tunnel2_address
    onprem_tunnel1_inside_ip = module.vpn.tunnel1_cgw_inside_address
    onprem_tunnel2_inside_ip = module.vpn.tunnel2_cgw_inside_address
    aws_tunnel1_inside_ip    = module.vpn.tunnel1_vgw_inside_address
    aws_tunnel2_inside_ip    = module.vpn.tunnel2_vgw_inside_address
    aws_vpc_cidr             = var.vpc_cidr
    onprem_cidr              = var.onprem_cidr
    psk_command              = "terraform output -json | jq '.vpn_tunnel1_preshared_key.value, .vpn_tunnel2_preshared_key.value'"
  }
}

#------------------------------------------------------------------------------
# EKS Outputs
#------------------------------------------------------------------------------

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_certificate_authority" {
  description = "EKS cluster CA certificate"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "eks_cluster_security_group_id" {
  description = "EKS cluster security group ID"
  value       = module.eks.cluster_security_group_id
}

output "eks_oidc_provider_arn" {
  description = "EKS OIDC Provider ARN (for IRSA)"
  value       = module.eks.oidc_provider_arn
}

output "eks_oidc_provider_url" {
  description = "EKS OIDC Provider URL (without https://)"
  value       = module.eks.oidc_provider_url
}

#------------------------------------------------------------------------------
# ECR Outputs
#------------------------------------------------------------------------------

output "ecr_repository_urls" {
  description = "ECR repository URLs"
  value       = module.ecr.repository_urls
}

#------------------------------------------------------------------------------
# RDS Outputs
#------------------------------------------------------------------------------

output "rds_cluster_endpoint" {
  description = "Aurora cluster writer endpoint"
  value       = module.rds.cluster_endpoint
}

output "rds_cluster_reader_endpoint" {
  description = "Aurora cluster reader endpoint"
  value       = module.rds.cluster_reader_endpoint
}

output "rds_cluster_port" {
  description = "Aurora cluster port"
  value       = module.rds.cluster_port
}

