#------------------------------------------------------------------------------
# ALB Module - Main Configuration
# Application Load Balancer for ECS Fargate
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
# Target Group (IP 타입 - Fargate 필수)
#------------------------------------------------------------------------------
resource "aws_lb_target_group" "this" {
  name        = "${var.env_name}-pii-tg"
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

  tags = merge(var.tags, { Name = "${var.env_name}-pii-tg" })
}

#------------------------------------------------------------------------------
# HTTP Listener
#------------------------------------------------------------------------------
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  tags = merge(var.tags, { Name = "${var.env_name}-http-listener" })
}
