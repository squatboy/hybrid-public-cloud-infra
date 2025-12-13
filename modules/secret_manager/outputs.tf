#------------------------------------------------------------------------------
# Secrets Manager Module - Outputs
#------------------------------------------------------------------------------

output "secret_arn" {
  description = "ARN of the Secrets Manager secret"
  value       = aws_secretsmanager_secret.db_secret.arn
}

output "secret_id" {
  description = "ID of the Secrets Manager secret"
  value       = aws_secretsmanager_secret.db_secret.id
}
