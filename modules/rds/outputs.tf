#------------------------------------------------------------------------------
# RDS Module - Outputs
#------------------------------------------------------------------------------

output "db_instance_id" {
  description = "ID of the RDS instance"
  value       = aws_db_instance.this.id
}

output "db_instance_identifier" {
  description = "Identifier of the RDS instance"
  value       = aws_db_instance.this.identifier
}

output "db_instance_arn" {
  description = "ARN of the RDS instance"
  value       = aws_db_instance.this.arn
}

output "cluster_endpoint" {
  description = "Endpoint for the RDS instance"
  value       = aws_db_instance.this.endpoint
}

output "cluster_reader_endpoint" {
  description = "Reader endpoint (same as primary for single instance)"
  value       = aws_db_instance.this.endpoint
}

output "cluster_port" {
  description = "Port of the RDS instance"
  value       = aws_db_instance.this.port
}

output "database_name" {
  description = "Name of the default database"
  value       = aws_db_instance.this.db_name
}

output "master_username" {
  description = "Master username for the database"
  value       = aws_db_instance.this.username
  sensitive   = true
}
