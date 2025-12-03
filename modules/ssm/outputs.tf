#------------------------------------------------------------------------------
# SSM Module - Outputs
#------------------------------------------------------------------------------

output "activation_id" {
  description = "SSM Activation ID (used for on-premise server registration)"
  value       = aws_ssm_activation.ecs_anywhere.id
}

output "activation_code" {
  description = "SSM Activation Code (used for on-premise server registration)"
  value       = aws_ssm_activation.ecs_anywhere.activation_code
  sensitive   = true
}

output "registration_limit" {
  description = "Maximum number of managed instances that can be registered"
  value       = aws_ssm_activation.ecs_anywhere.registration_limit
}

output "expiration_date" {
  description = "Expiration date of the activation"
  value       = aws_ssm_activation.ecs_anywhere.expiration_date
}
