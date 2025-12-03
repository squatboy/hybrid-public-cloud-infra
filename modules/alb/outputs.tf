#------------------------------------------------------------------------------
# ALB Module - Outputs
#------------------------------------------------------------------------------

output "alb_id" {
  description = "ALB ID"
  value       = aws_lb.this.id
}

output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.this.arn
}

output "dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.this.dns_name
}

output "zone_id" {
  description = "ALB hosted zone ID"
  value       = aws_lb.this.zone_id
}

# Cloud Target Group Outputs
output "target_group_cloud_arn" {
  description = "Cloud (Fargate) target group ARN"
  value       = aws_lb_target_group.cloud.arn
}

output "target_group_cloud_name" {
  description = "Cloud (Fargate) target group name"
  value       = aws_lb_target_group.cloud.name
}

# OnPrem Target Group Outputs
output "target_group_onprem_arn" {
  description = "OnPrem (ECS Anywhere) target group ARN"
  value       = aws_lb_target_group.onprem.arn
}

output "target_group_onprem_name" {
  description = "OnPrem (ECS Anywhere) target group name"
  value       = aws_lb_target_group.onprem.name
}

# Legacy output for backward compatibility
output "target_group_arn" {
  description = "Cloud target group ARN (deprecated, use target_group_cloud_arn)"
  value       = aws_lb_target_group.cloud.arn
}

output "target_group_name" {
  description = "Cloud target group name (deprecated, use target_group_cloud_name)"
  value       = aws_lb_target_group.cloud.name
}

output "http_listener_arn" {
  description = "HTTP listener ARN"
  value       = aws_lb_listener.http.arn
}
