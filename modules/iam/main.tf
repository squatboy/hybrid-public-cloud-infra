#------------------------------------------------------------------------------
# IAM Module - Main Configuration
# ECS Task Execution and Task Roles
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# ECS Task Execution Role
# Fargate가 ECR에서 이미지를 당겨오고 CloudWatch에 로그를 쓸 권한
#------------------------------------------------------------------------------

resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.project_name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = merge(var.tags, { Name = "${var.project_name}-ecs-task-execution-role" })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#------------------------------------------------------------------------------
# ECS Task Role
# 컨테이너 내부 앱이 AWS 서비스(S3, Secrets Manager 등)를 호출할 때 사용
#------------------------------------------------------------------------------

resource "aws_iam_role" "ecs_task" {
  name = "${var.project_name}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = merge(var.tags, { Name = "${var.project_name}-ecs-task-role" })
}

#------------------------------------------------------------------------------
# SSM Managed Instance Role (ECS Anywhere용)
# 온프레미스 서버가 AWS Systems Manager 및 ECS와 통신할 권한
#------------------------------------------------------------------------------

resource "aws_iam_role" "ssm_managed_instance" {
  name = "${var.project_name}-ssm-managed-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ssm.amazonaws.com"
      }
    }]
  })

  tags = merge(var.tags, { Name = "${var.project_name}-ssm-managed-role" })
}

# SSM 핵심 정책 - Systems Manager Agent가 AWS와 통신하는 데 필요
resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.ssm_managed_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ECS 컨테이너 서비스 정책 - ECS Anywhere 인스턴스가 ECS 클러스터에 등록되고 태스크를 실행하는 데 필요
resource "aws_iam_role_policy_attachment" "ecs_anywhere_policy" {
  role       = aws_iam_role.ssm_managed_instance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

