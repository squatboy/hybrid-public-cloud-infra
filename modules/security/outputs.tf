#------------------------------------------------------------------------------
# Security Module - Outputs
#------------------------------------------------------------------------------

output "alb_sg_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "ecs_sg_id" {
  description = "ID of the ECS security group"
  value       = aws_security_group.ecs.id
}

output "vpn_sg_id" {
  description = "ID of the VPN access security group"
  value       = aws_security_group.vpn_access.id
}

output "vpn_sg_name" {
  description = "Name of the VPN access security group"
  value       = aws_security_group.vpn_access.name
}

output "private_default_sg_id" {
  description = "ID of the private default security group"
  value       = aws_security_group.private_default.id
}

output "private_default_sg_name" {
  description = "Name of the private default security group"
  value       = aws_security_group.private_default.name
}
