#------------------------------------------------------------------------------
# ECS Module - Main Configuration
# ECS Cluster, Task Definition, and Service for Fargate
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# CloudWatch Log Group
#------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.env_name}-pii-api"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, { Name = "${var.env_name}-pii-api-logs" })
}

#------------------------------------------------------------------------------
# ECS Cluster
#------------------------------------------------------------------------------
resource "aws_ecs_cluster" "this" {
  name = "${var.env_name}-pii-cluster"

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  tags = merge(var.tags, { Name = "${var.env_name}-pii-cluster" })
}

#------------------------------------------------------------------------------
# ECS Task Definition
#------------------------------------------------------------------------------
resource "aws_ecs_task_definition" "this" {
  family                   = "${var.env_name}-pii-api-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "pii-api"
      image     = var.container_image
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      environment = [
        { name = "NODE_ENV", value = "production" },
        { name = "VAULT_ADDR", value = "http://${var.onprem_vault_ip}:8200" },
        { name = "PORT", value = tostring(var.container_port) }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.this.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:${var.container_port}/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = merge(var.tags, { Name = "${var.env_name}-pii-api-task" })
}

#------------------------------------------------------------------------------
# ECS Service
#------------------------------------------------------------------------------
resource "aws_ecs_service" "this" {
  name            = "${var.env_name}-pii-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [var.ecs_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "pii-api"
    container_port   = var.container_port
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  # Task Definition 변경 시 새 배포 트리거
  force_new_deployment = true

  tags = merge(var.tags, { Name = "${var.env_name}-pii-service" })

  lifecycle {
    ignore_changes = [desired_count]
  }
}
