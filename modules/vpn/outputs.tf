#------------------------------------------------------------------------------
# VPN Module - Outputs
#------------------------------------------------------------------------------

output "vpn_connection_id" {
  description = "The ID of the VPN connection"
  value       = aws_vpn_connection.this.id
}

output "vpn_gateway_id" {
  description = "The ID of the VPN Gateway"
  value       = aws_vpn_gateway.this.id
}

output "customer_gateway_id" {
  description = "The ID of the Customer Gateway"
  value       = aws_customer_gateway.this.id
}

# Tunnel 1 Information
output "tunnel1_address" {
  description = "Tunnel 1 - AWS VPN endpoint public IP"
  value       = aws_vpn_connection.this.tunnel1_address
}

output "tunnel1_preshared_key" {
  description = "Tunnel 1 - Pre-shared key (PSK)"
  value       = aws_vpn_connection.this.tunnel1_preshared_key
  sensitive   = true
}

output "tunnel1_cgw_inside_address" {
  description = "Tunnel 1 - Customer Gateway inside IP"
  value       = aws_vpn_connection.this.tunnel1_cgw_inside_address
}

output "tunnel1_vgw_inside_address" {
  description = "Tunnel 1 - VPN Gateway inside IP"
  value       = aws_vpn_connection.this.tunnel1_vgw_inside_address
}

# Tunnel 2 Information
output "tunnel2_address" {
  description = "Tunnel 2 - AWS VPN endpoint public IP"
  value       = aws_vpn_connection.this.tunnel2_address
}

output "tunnel2_preshared_key" {
  description = "Tunnel 2 - Pre-shared key (PSK)"
  value       = aws_vpn_connection.this.tunnel2_preshared_key
  sensitive   = true
}

output "tunnel2_cgw_inside_address" {
  description = "Tunnel 2 - Customer Gateway inside IP"
  value       = aws_vpn_connection.this.tunnel2_cgw_inside_address
}

output "tunnel2_vgw_inside_address" {
  description = "Tunnel 2 - VPN Gateway inside IP"
  value       = aws_vpn_connection.this.tunnel2_vgw_inside_address
}
