#------------------------------------------------------------------------------
# IAM Module - Outputs
#------------------------------------------------------------------------------

output "cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  value       = aws_iam_role.cluster.arn
}

output "cluster_role_name" {
  description = "Name of the EKS cluster IAM role"
  value       = aws_iam_role.cluster.name
}

output "fargate_role_arn" {
  description = "ARN of the Fargate pod execution IAM role"
  value       = aws_iam_role.fargate.arn
}

output "fargate_role_name" {
  description = "Name of the Fargate pod execution IAM role"
  value       = aws_iam_role.fargate.name
}
