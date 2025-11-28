#------------------------------------------------------------------------------
# Security Module - Outputs
#------------------------------------------------------------------------------

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
