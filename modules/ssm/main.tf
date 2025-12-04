#------------------------------------------------------------------------------
# SSM Module - Main Configuration
# ECS Anywhere 온프레미스 서버 등록을 위한 SSM Activation
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# SSM Activation
# 온프레미스 서버를 ECS 클러스터에 등록할 때 사용하는 일회용 코드 발급
#------------------------------------------------------------------------------
resource "aws_ssm_activation" "ecs_anywhere" {
  name               = "${var.env_name}-ecs-anywhere-activation"
  description        = "Activation for On-Premise ECS Anywhere Instances"
  iam_role           = var.ssm_role_name
  registration_limit = var.registration_limit

  # SSM Activation은 최대 30일까지만 유효
  # 만료 후 새로운 Activation을 생성해야 함
  expiration_date = timeadd(timestamp(), "720h")  # 30일

  tags = merge(var.tags, { Name = "${var.env_name}-ecs-anywhere-activation" })

  lifecycle {
    # expiration_date 변경으로 인한 불필요한 리소스 재생성 방지
    ignore_changes = [expiration_date]
  }
}
