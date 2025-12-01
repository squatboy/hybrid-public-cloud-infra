#------------------------------------------------------------------------------
# ECS Module - Outputs
#------------------------------------------------------------------------------

output "cluster_id" {
  description = "ECS cluster ID"
  value       = aws_ecs_cluster.this.id
}

output "cluster_arn" {
  description = "ECS cluster ARN"
  value       = aws_ecs_cluster.this.arn
}

output "cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.this.name
}

output "service_id" {
  description = "ECS service ID"
  value       = aws_ecs_service.this.id
}

output "service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.this.name
}

output "task_definition_arn" {
  description = "ECS task definition ARN"
  value       = aws_ecs_task_definition.this.arn
}

output "task_definition_family" {
  description = "ECS task definition family"
  value       = aws_ecs_task_definition.this.family
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.this.name
}
