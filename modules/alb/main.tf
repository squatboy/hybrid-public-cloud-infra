#------------------------------------------------------------------------------
# ALB Module - Main Configuration
# Application Load Balancer with Path-based Routing for Hybrid Architecture
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Application Load Balancer
#------------------------------------------------------------------------------
resource "aws_lb" "this" {
  name               = "${var.env_name}-pii-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnets

  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(var.tags, { Name = "${var.env_name}-pii-alb" })
}

#------------------------------------------------------------------------------
# Target Group - Cloud (Fargate)
# IP 타입 필수 - Fargate awsvpc 네트워크 모드 사용
#------------------------------------------------------------------------------
resource "aws_lb_target_group" "cloud" {
  name        = "${var.env_name}-tg-cloud"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 30
    matcher             = "200-299"
  }

  tags = merge(var.tags, { Name = "${var.env_name}-tg-cloud" })
}

#------------------------------------------------------------------------------
# Target Group - OnPrem (ECS Anywhere)
# IP 타입 - VPN을 통해 온프레미스 서버 IP로 직접 라우팅
#------------------------------------------------------------------------------
resource "aws_lb_target_group" "onprem" {
  name        = "${var.env_name}-tg-onprem"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 30
    matcher             = "200-299"
  }

  tags = merge(var.tags, { Name = "${var.env_name}-tg-onprem" })
}

#------------------------------------------------------------------------------
# Target Group Attachment - OnPrem Server (정적 IP 등록)
# 온프레미스 서버(vm-app-01)를 Target Group에 수동 등록
#------------------------------------------------------------------------------
resource "aws_lb_target_group_attachment" "onprem_server" {
  target_group_arn  = aws_lb_target_group.onprem.arn
  target_id         = var.onprem_server_ip
  port              = var.container_port
  availability_zone = "all"  # Cross-zone (VPN을 통한 온프레미스 접근)
}

#------------------------------------------------------------------------------
# HTTP Listener
# 기본 액션: Cloud(Fargate) Target Group으로 전송
#------------------------------------------------------------------------------
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cloud.arn
  }

  tags = merge(var.tags, { Name = "${var.env_name}-http-listener" })
}

#------------------------------------------------------------------------------
# Listener Rule - PII 경로 라우팅
# /pii/* 경로 요청은 OnPrem Target Group으로 전송
#------------------------------------------------------------------------------
resource "aws_lb_listener_rule" "pii_routing" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.onprem.arn
  }

  condition {
    path_pattern {
      values = ["/pii", "/pii/*"]
    }
  }

  tags = merge(var.tags, { Name = "${var.env_name}-pii-routing-rule" })
}
