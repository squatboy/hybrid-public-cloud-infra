#------------------------------------------------------------------------------
# ECS Module - Main Configuration
# ECS Cluster with Fargate (Cloud) and External (OnPrem) Services
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# CloudWatch Log Groups
#------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "cloud" {
  name              = "/ecs/${var.env_name}-cloud"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, { Name = "${var.env_name}-cloud-logs" })
}

resource "aws_cloudwatch_log_group" "onprem" {
  name              = "/ecs/${var.env_name}-onprem"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, { Name = "${var.env_name}-onprem-logs" })
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
# Cloud Task Definition (Fargate)
# awsvpc 네트워크 모드 - ALB와 연동
#------------------------------------------------------------------------------
resource "aws_ecs_task_definition" "cloud" {
  family                   = "${var.env_name}-cloud-task"
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
        { name = "IS_ONPREM", value = "false" },
        { name = "PORT", value = tostring(var.container_port) }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.cloud.name
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

  tags = merge(var.tags, { Name = "${var.env_name}-cloud-task" })
}

#------------------------------------------------------------------------------
# Cloud Service (Fargate)
# ALB와 연동되어 일반 트래픽 처리
#------------------------------------------------------------------------------
resource "aws_ecs_service" "cloud" {
  name            = "${var.env_name}-cloud-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.cloud.arn
  desired_count   = var.cloud_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [var.ecs_sg_id]
    assign_public_ip = var.enable_nat_gateway ? false : true
  }

  load_balancer {
    target_group_arn = var.target_group_cloud_arn
    container_name   = "pii-api"
    container_port   = var.container_port
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  force_new_deployment               = true

  tags = merge(var.tags, { Name = "${var.env_name}-cloud-service" })

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }
}

#------------------------------------------------------------------------------
# OnPrem Task Definition (External / ECS Anywhere)
# bridge 네트워크 모드 - Host Port 8000 매핑
#------------------------------------------------------------------------------
resource "aws_ecs_task_definition" "onprem" {
  family                   = "${var.env_name}-onprem-task"
  network_mode             = "bridge"
  requires_compatibilities = ["EXTERNAL"]
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
        { name = "IS_ONPREM", value = "true" },
        { name = "VAULT_ADDR", value = "http://${var.onprem_vault_ip}:8200" },
        { name = "PORT", value = tostring(var.container_port) }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.onprem.name
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

  tags = merge(var.tags, { Name = "${var.env_name}-onprem-task" })
}

#------------------------------------------------------------------------------
# OnPrem Service (External / ECS Anywhere)
# ALB 직접 연동 없음 - Target Group Attachment로 IP 기반 라우팅
# desired_count는 ECS Anywhere 인스턴스 등록 후 변경
#------------------------------------------------------------------------------
resource "aws_ecs_service" "onprem" {
  name            = "${var.env_name}-onprem-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.onprem.arn
  desired_count   = var.onprem_desired_count
  launch_type     = "EXTERNAL"

  # EXTERNAL launch type은 network_configuration 불필요 (자체 네트워크 사용)
  # load_balancer 블록 제거 - ALB Target Group Attachment로 정적 IP 등록

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 0  # EXTERNAL은 0으로 설정 권장
  force_new_deployment               = true

  tags = merge(var.tags, { Name = "${var.env_name}-onprem-service" })

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }
}
