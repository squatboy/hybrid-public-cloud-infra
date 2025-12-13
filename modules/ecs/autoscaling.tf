#------------------------------------------------------------------------------
# ECS Auto Scaling Configuration - based on CPU utilization
#------------------------------------------------------------------------------

# Auto Scaling Target Registration
resource "aws_appautoscaling_target" "cloud_target" {
  max_capacity       = var.ecs_cloud_max_count
  min_capacity       = var.cloud_desired_count
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.cloud.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = [aws_ecs_service.cloud]
}

# Auto Scaling Policy - CPU Target Tracking
resource "aws_appautoscaling_policy" "cloud_cpu_scaling" {
  name               = "${var.env_name}-cloud-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.cloud_target.resource_id
  scalable_dimension = aws_appautoscaling_target.cloud_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.cloud_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = var.ecs_cloud_target_cpu # 기본값: 70%
    scale_in_cooldown  = 300                  
    scale_out_cooldown = 60                      
  }
}