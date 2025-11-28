#------------------------------------------------------------------------------
# Root Module - Main Configuration
# 모듈들을 조립하여 인프라를 구성
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# VPC Module
#------------------------------------------------------------------------------
module "vpc" {
  source = "./modules/vpc"

  env_name        = var.environment
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  azs             = var.availability_zones
  tags            = local.common_tags
}

#------------------------------------------------------------------------------
# VPN Module
#------------------------------------------------------------------------------
module "vpn" {
  source = "./modules/vpn"

  env_name         = var.environment
  vpc_id           = module.vpc.vpc_id
  onprem_public_ip = var.onprem_public_ip
  onprem_cidr      = var.onprem_cidr
  route_table_id   = module.vpc.private_route_table_id
  bgp_asn          = var.bgp_asn
  tags             = local.common_tags

  depends_on = [module.vpc]
}

#------------------------------------------------------------------------------
# Security Module
#------------------------------------------------------------------------------
module "security" {
  source = "./modules/security"

  env_name       = var.environment
  vpc_id         = module.vpc.vpc_id
  vpc_cidr       = var.vpc_cidr
  onprem_cidr    = var.onprem_cidr
  allow_vpc_cidr = true
  tags           = local.common_tags

  depends_on = [module.vpc]
}
