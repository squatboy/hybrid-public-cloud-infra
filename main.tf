#------------------------------------------------------------------------------
# Root Module - Main Configuration
# 모듈들을 조립하여 인프라를 구성
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Generate Random DB Master Password
#------------------------------------------------------------------------------

resource "random_password" "db_master" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

#------------------------------------------------------------------------------
# VPC Module
#------------------------------------------------------------------------------
module "vpc" {
  source = "./modules/vpc"

  env_name           = var.environment
  vpc_cidr           = var.vpc_cidr
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  azs                = var.availability_zones
  enable_nat_gateway = var.enable_nat_gateway
  tags               = local.common_tags
}

#------------------------------------------------------------------------------
# VPN Module
#------------------------------------------------------------------------------
module "vpn" {
  source = "./modules/vpn"

  env_name              = var.environment
  vpc_id                = module.vpc.vpc_id
  onprem_public_ip      = var.onprem_public_ip
  onprem_cidr           = var.onprem_cidr
  route_table_id        = module.vpc.private_route_table_id
  public_route_table_id = module.vpc.public_route_table_id
  bgp_asn               = var.bgp_asn
  tags                  = local.common_tags

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
  container_port = var.ecs_container_port
  allow_vpc_cidr = true
  tags           = local.common_tags

  depends_on = [module.vpc]
}

#------------------------------------------------------------------------------
# IAM Module
#------------------------------------------------------------------------------
module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  github_repo  = var.github_repo
  tags         = local.common_tags
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
  master_password     = random_password.db_master.result
  database_name       = var.db_name
  min_capacity        = var.db_min_capacity
  max_capacity        = var.db_max_capacity
  deletion_protection = var.environment == "prod" ? true : false
  skip_final_snapshot = var.environment == "prod" ? false : true
  tags                = local.common_tags

  depends_on = [module.vpc, module.security]
}

#------------------------------------------------------------------------------
# Secrets Manager Module
#------------------------------------------------------------------------------
module "secret_manager" {
  source = "./modules/secret_manager"

  env_name        = var.environment
  project_name    = var.project_name
  db_password     = random_password.db_master.result
  db_host         = module.rds.cluster_endpoint
  db_port         = tostring(module.rds.cluster_port)
  db_name         = module.rds.database_name
  master_username = module.rds.master_username
  tags            = local.common_tags

  depends_on = [module.rds]
}

#------------------------------------------------------------------------------
# ALB Module
#------------------------------------------------------------------------------
module "alb" {
  source = "./modules/alb"

  env_name         = var.environment
  vpc_id           = module.vpc.vpc_id
  public_subnets   = module.vpc.public_subnet_ids
  alb_sg_id        = module.security.alb_sg_id
  container_port   = var.ecs_container_port
  onprem_server_ip = var.onprem_server_ip
  tags             = local.common_tags

  depends_on = [module.vpc, module.security]
}

#------------------------------------------------------------------------------
# WAF Module
#------------------------------------------------------------------------------
module "waf" {
  source = "./modules/waf"

  env_name = var.environment
  alb_arn  = module.alb.alb_arn
  tags     = local.common_tags

  depends_on = [module.alb]
}

#------------------------------------------------------------------------------
# ECS Module
#------------------------------------------------------------------------------
module "ecs" {
  source = "./modules/ecs"

  env_name               = var.environment
  aws_region             = var.aws_region
  private_subnets        = module.vpc.private_subnet_ids
  ecs_sg_id              = module.security.ecs_sg_id
  target_group_cloud_arn = module.alb.target_group_cloud_arn
  execution_role_arn     = module.iam.execution_role_arn
  task_role_arn          = module.iam.task_role_arn
  container_image        = "${module.ecr.repository_urls["pii-system/pii-api"]}:latest"
  container_port         = var.ecs_container_port
  container_cpu          = var.ecs_container_cpu
  container_memory       = var.ecs_container_memory
  cloud_desired_count    = var.ecs_cloud_desired_count
  ecs_cloud_max_count    = var.ecs_cloud_max_count
  ecs_cloud_target_cpu   = var.ecs_cloud_target_cpu
  onprem_desired_count   = var.ecs_onprem_desired_count
  onprem_vault_ip        = var.onprem_vault_ip
  vault_role_id          = var.vault_role_id
  vault_secret_id        = var.vault_secret_id
  enable_nat_gateway     = var.enable_nat_gateway
  db_secret_arn          = module.secret_manager.secret_arn
  tags                   = local.common_tags

  depends_on = [module.vpc, module.security, module.alb, module.iam, module.ecr, module.secret_manager]
}

#------------------------------------------------------------------------------
# SSM Module (ECS Anywhere Activation)
#------------------------------------------------------------------------------
module "ssm" {
  source = "./modules/ssm"

  env_name           = var.environment
  ssm_role_name      = module.iam.ssm_role_name
  registration_limit = 5
  tags               = local.common_tags

  depends_on = [module.iam]
}

