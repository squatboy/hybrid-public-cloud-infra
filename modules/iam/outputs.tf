#------------------------------------------------------------------------------
# IAM Module - Outputs
#------------------------------------------------------------------------------

output "execution_role_arn" {
  description = "ARN of the ECS task execution IAM role"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "execution_role_name" {
  description = "Name of the ECS task execution IAM role"
  value       = aws_iam_role.ecs_task_execution.name
}

output "task_role_arn" {
  description = "ARN of the ECS task IAM role"
  value       = aws_iam_role.ecs_task.arn
}

output "task_role_name" {
  description = "Name of the ECS task IAM role"
  value       = aws_iam_role.ecs_task.name
}

#------------------------------------------------------------------------------
# SSM Managed Instance Role Outputs
#------------------------------------------------------------------------------

output "ssm_role_arn" {
  description = "ARN of the SSM managed instance IAM role"
  value       = aws_iam_role.ssm_managed_instance.arn
}

output "ssm_role_name" {
  description = "Name of the SSM managed instance IAM role"
  value       = aws_iam_role.ssm_managed_instance.name
}

#------------------------------------------------------------------------------
# GitHub Actions OIDC Role Outputs
#------------------------------------------------------------------------------

output "github_actions_role_arn" {
  description = "ARN of the IAM Role for GitHub Actions OIDC"
  value       = aws_iam_role.github_actions.arn
}
