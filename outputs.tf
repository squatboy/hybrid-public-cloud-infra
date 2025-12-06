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
# ECS Outputs
#------------------------------------------------------------------------------

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.cluster_name
}

output "ecs_cloud_service_name" {
  description = "ECS Cloud (Fargate) service name"
  value       = module.ecs.cloud_service_name
}

output "ecs_onprem_service_name" {
  description = "ECS OnPrem (External) service name"
  value       = module.ecs.onprem_service_name
}

#------------------------------------------------------------------------------
# SSM Outputs (ECS Anywhere 등록용)
#------------------------------------------------------------------------------

output "ssm_activation_id" {
  description = "SSM Activation ID for ECS Anywhere registration"
  value       = module.ssm.activation_id
}

output "ssm_activation_code" {
  description = "SSM Activation Code for ECS Anywhere registration (SENSITIVE)"
  value       = module.ssm.activation_code
  sensitive   = true
}

output "ecs_anywhere_registration_command" {
  description = "Command to register on-premise server as ECS Anywhere instance"
  sensitive   = true
  value       = <<-EOT
    # vm-app-01에서 실행할 명령어:
    curl --proto "https" -o "/tmp/ecs-anywhere-install.sh" "https://amazon-ecs-agent.s3.amazonaws.com/ecs-anywhere-install-latest.sh"
    sudo bash /tmp/ecs-anywhere-install.sh \
      --cluster ${module.ecs.cluster_name} \
      --activation-id ${module.ssm.activation_id} \
      --activation-code ${module.ssm.activation_code} \
      --region ${var.aws_region}
  EOT
}

#------------------------------------------------------------------------------
# ALB Outputs
#------------------------------------------------------------------------------

output "alb_dns_name" {
  description = "ALB DNS name for accessing the application"
  value       = module.alb.dns_name
}

output "alb_zone_id" {
  description = "ALB hosted zone ID"
  value       = module.alb.zone_id
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

#------------------------------------------------------------------------------
# GitHub Actions OIDC Outputs
#------------------------------------------------------------------------------

output "github_actions_role_arn" {
  description = "ARN of the IAM Role for GitHub Actions OIDC"
  value       = module.iam.github_actions_role_arn
}
