#------------------------------------------------------------------------------
# Security Module - Main Configuration
# ALB, ECS, VPN 및 VPC 내부 통신을 위한 Security Groups
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# ALB Security Group (인터넷 -> ALB)
#------------------------------------------------------------------------------
resource "aws_security_group" "alb" {
  name        = "${var.env_name}-alb-sg"
  description = "Allow HTTP inbound traffic to ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.env_name}-alb-sg" })

  lifecycle {
    create_before_destroy = true
  }
}

#------------------------------------------------------------------------------
# ECS Security Group (ALB -> ECS)
#------------------------------------------------------------------------------
resource "aws_security_group" "ecs" {
  name        = "${var.env_name}-ecs-sg"
  description = "Allow traffic from ALB only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Container port from ALB"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.env_name}-ecs-sg" })

  lifecycle {
    create_before_destroy = true
  }
}

#------------------------------------------------------------------------------
# VPN Access Security Group
# 온프레미스 및 VPC 내부 통신 허용
#------------------------------------------------------------------------------
resource "aws_security_group" "vpn_access" {
  name        = "${var.env_name}-vpn-sg"
  description = "Allow traffic from On-Premise via VPN and VPC internal"
  vpc_id      = var.vpc_id

  # 인바운드: 온프레미스에서의 모든 트래픽 허용
  ingress {
    description = "Allow all from On-Premise"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.onprem_cidr]
  }

  # 인바운드: VPC 내부 통신 허용 (동일 SG 내)
  ingress {
    description = "Allow VPC internal (self)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # 인바운드: VPC CIDR 전체 허용 (선택적)
  dynamic "ingress" {
    for_each = var.allow_vpc_cidr ? [1] : []
    content {
      description = "Allow all from VPC"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = [var.vpc_cidr]
    }
  }

  # 아웃바운드: 모든 트래픽 허용
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.env_name}-vpn-sg" })

  lifecycle {
    create_before_destroy = true
  }
}

#------------------------------------------------------------------------------
# Private Subnet Default Security Group (RDS용)
#------------------------------------------------------------------------------
resource "aws_security_group" "private_default" {
  name        = "${var.env_name}-private-default-sg"
  description = "Default security group for private subnet resources (RDS)"
  vpc_id      = var.vpc_id

  # 인바운드: VPN SG에서의 트래픽 허용
  ingress {
    description     = "Allow from VPN SG"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.vpn_access.id]
  }

  # 인바운드: 자체 SG 내 통신 허용
  ingress {
    description = "Allow internal (self)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # 아웃바운드: 모든 트래픽 허용
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.env_name}-private-default-sg" })

  lifecycle {
    create_before_destroy = true
  }
}

#------------------------------------------------------------------------------
# RDS Security Group Rule - ECS에서 RDS 접근 허용
#------------------------------------------------------------------------------
resource "aws_security_group_rule" "rds_from_ecs" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs.id
  security_group_id        = aws_security_group.private_default.id
  description              = "Allow MySQL from ECS"
}
