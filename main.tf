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

#------------------------------------------------------------------------------
# IAM Module
#------------------------------------------------------------------------------
module "iam" {
  source = "./modules/iam"

  cluster_name = var.eks_cluster_name
  aws_region   = var.aws_region
  tags         = local.common_tags
}

#------------------------------------------------------------------------------
# EKS Module
#------------------------------------------------------------------------------
module "eks" {
  source = "./modules/eks"

  cluster_name       = var.eks_cluster_name
  cluster_version    = var.eks_cluster_version
  cluster_role_arn   = module.iam.cluster_role_arn
  fargate_role_arn   = module.iam.fargate_role_arn
  private_subnet_ids = module.vpc.private_subnet_ids
  security_group_ids = [module.security.private_default_sg_id]
  fargate_namespaces = var.fargate_namespaces
  tags               = local.common_tags

  depends_on = [module.iam, module.vpc]
}

#------------------------------------------------------------------------------
# ECR Module
#------------------------------------------------------------------------------
module "ecr" {
  source = "./modules/ecr"

  repository_names = var.ecr_repository_names
  tags             = local.common_tags
}

#------------------------------------------------------------------------------
# RDS Module (Aurora Serverless v2)
#------------------------------------------------------------------------------
module "rds" {
  source = "./modules/rds"

  env_name            = var.environment
  private_subnet_ids  = module.vpc.private_subnet_ids
  security_group_ids  = [module.security.private_default_sg_id]
  master_password     = var.db_master_password
  database_name       = var.db_name
  min_capacity        = var.db_min_capacity
  max_capacity        = var.db_max_capacity
  deletion_protection = var.environment == "prod" ? true : false
  skip_final_snapshot = var.environment == "prod" ? false : true
  tags                = local.common_tags

  depends_on = [module.vpc, module.security]
}

