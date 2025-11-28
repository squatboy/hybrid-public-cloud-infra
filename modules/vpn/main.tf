#------------------------------------------------------------------------------
# VPN Module - Main Configuration
# Site-to-Site VPN Connection for Hybrid Cloud
#------------------------------------------------------------------------------

# Customer Gateway (온프레미스 측 정의)
resource "aws_customer_gateway" "this" {
  bgp_asn    = var.bgp_asn
  ip_address = var.onprem_public_ip
  type       = "ipsec.1"

  tags = merge(var.tags, { Name = "${var.env_name}-cgw" })
}

# Virtual Private Gateway (AWS 측 VPN Gateway)
resource "aws_vpn_gateway" "this" {
  vpc_id = var.vpc_id

  tags = merge(var.tags, { Name = "${var.env_name}-vgw" })
}

# VPN Connection (터널 생성)
resource "aws_vpn_connection" "this" {
  vpn_gateway_id      = aws_vpn_gateway.this.id
  customer_gateway_id = aws_customer_gateway.this.id
  type                = "ipsec.1"
  static_routes_only  = true

  tags = merge(var.tags, { Name = "${var.env_name}-s2s-vpn" })
}

# VPN Static Route (AWS -> OnPrem 트래픽 라우팅)
resource "aws_vpn_connection_route" "onprem" {
  destination_cidr_block = var.onprem_cidr
  vpn_connection_id      = aws_vpn_connection.this.id
}

# Route Propagation (Private Subnet이 VPN 경로를 알게 함)
resource "aws_vpn_gateway_route_propagation" "this" {
  vpn_gateway_id = aws_vpn_gateway.this.id
  route_table_id = var.route_table_id
}
