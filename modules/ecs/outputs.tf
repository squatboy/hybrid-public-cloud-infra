#------------------------------------------------------------------------------
# ECS Module - Outputs
#------------------------------------------------------------------------------

# Cluster Outputs
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

# Cloud Service Outputs
output "cloud_service_id" {
  description = "Cloud (Fargate) ECS service ID"
  value       = aws_ecs_service.cloud.id
}

output "cloud_service_name" {
  description = "Cloud (Fargate) ECS service name"
  value       = aws_ecs_service.cloud.name
}

output "cloud_task_definition_arn" {
  description = "Cloud (Fargate) ECS task definition ARN"
  value       = aws_ecs_task_definition.cloud.arn
}

output "cloud_task_definition_family" {
  description = "Cloud (Fargate) ECS task definition family"
  value       = aws_ecs_task_definition.cloud.family
}

# OnPrem Service Outputs
output "onprem_service_id" {
  description = "OnPrem (External) ECS service ID"
  value       = aws_ecs_service.onprem.id
}

output "onprem_service_name" {
  description = "OnPrem (External) ECS service name"
  value       = aws_ecs_service.onprem.name
}

output "onprem_task_definition_arn" {
  description = "OnPrem (External) ECS task definition ARN"
  value       = aws_ecs_task_definition.onprem.arn
}

output "onprem_task_definition_family" {
  description = "OnPrem (External) ECS task definition family"
  value       = aws_ecs_task_definition.onprem.family
}

# Log Group Outputs
output "cloud_log_group_name" {
  description = "Cloud CloudWatch log group name"
  value       = aws_cloudwatch_log_group.cloud.name
}

output "onprem_log_group_name" {
  description = "OnPrem CloudWatch log group name"
  value       = aws_cloudwatch_log_group.onprem.name
}

# Legacy outputs for backward compatibility
output "service_id" {
  description = "Cloud ECS service ID (deprecated, use cloud_service_id)"
  value       = aws_ecs_service.cloud.id
}

output "service_name" {
  description = "Cloud ECS service name (deprecated, use cloud_service_name)"
  value       = aws_ecs_service.cloud.name
}

output "task_definition_arn" {
  description = "Cloud task definition ARN (deprecated, use cloud_task_definition_arn)"
  value       = aws_ecs_task_definition.cloud.arn
}

output "task_definition_family" {
  description = "Cloud task definition family (deprecated, use cloud_task_definition_family)"
  value       = aws_ecs_task_definition.cloud.family
}

output "log_group_name" {
  description = "Cloud log group name (deprecated, use cloud_log_group_name)"
  value       = aws_cloudwatch_log_group.cloud.name
}

# Auto Scaling Outputs
output "autoscaling_target_id" {
  description = "Auto Scaling target resource ID for Cloud service"
  value       = aws_appautoscaling_target.cloud_target.id
}

output "autoscaling_target_arn" {
  description = "Auto Scaling target ARN for Cloud service"
  value       = aws_appautoscaling_target.cloud_target.arn
}

output "autoscaling_policy_arn" {
  description = "Auto Scaling policy ARN for CPU tracking"
  value       = aws_appautoscaling_policy.cloud_cpu_scaling.arn
}

output "autoscaling_policy_name" {
  description = "Auto Scaling policy name for CPU tracking"
  value       = aws_appautoscaling_policy.cloud_cpu_scaling.name
}

output "autoscaling_target_min_capacity" {
  description = "Minimum capacity for Auto Scaling target"
  value       = aws_appautoscaling_target.cloud_target.min_capacity
}

output "autoscaling_target_max_capacity" {
  description = "Maximum capacity for Auto Scaling target"
  value       = aws_appautoscaling_target.cloud_target.max_capacity
}
