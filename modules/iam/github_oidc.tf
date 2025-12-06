#------------------------------------------------------------------------------
# GitHub OIDC Configuration for CI/CD
#------------------------------------------------------------------------------

# GitHub OIDC Provider 생성
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  # GitHub의 루트 CA 썸프린트 (AWS 공식 문서 제공 값)
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]

  tags = merge(var.tags, { Name = "${var.project_name}-github-oidc-provider" })
}

# CI/CD용 IAM Role 생성
resource "aws_iam_role" "github_actions" {
  name = "${var.project_name}-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            # 보안 핵심: 오직 지정된 레포지토리에서만 이 역할을 쓸 수 있음
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:*"
          }
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = merge(var.tags, { Name = "${var.project_name}-github-actions-role" })
}

#------------------------------------------------------------------------------
# 권한 부여 (Policy Attachment)
#------------------------------------------------------------------------------

# 1. ECR 권한 (PowerUser)
resource "aws_iam_role_policy_attachment" "ecr_poweruser" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# 2. ECS 서비스 업데이트 권한 (Custom Policy)
resource "aws_iam_policy" "ecs_deploy" {
  name        = "${var.project_name}-ecs-deploy-policy"
  description = "Allow updating ECS services for CI/CD deployment"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:RegisterTaskDefinition",
          "ecs:DescribeTaskDefinition",
          "iam:PassRole" # Task 실행 역할(Execution Role)을 전달하기 위해 필요
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(var.tags, { Name = "${var.project_name}-ecs-deploy-policy" })
}

resource "aws_iam_role_policy_attachment" "ecs_deploy_attach" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.ecs_deploy.arn
}
