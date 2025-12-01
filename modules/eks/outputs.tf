#------------------------------------------------------------------------------
# EKS Module - Outputs
#------------------------------------------------------------------------------

output "cluster_id" {
  description = "ID of the EKS cluster"
  value       = aws_eks_cluster.this.id
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.this.name
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  description = "Endpoint URL for the EKS cluster API server"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data for cluster authentication"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_version" {
  description = "Kubernetes version of the EKS cluster"
  value       = aws_eks_cluster.this.version
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "fargate_profile_id" {
  description = "ID of the Fargate profile"
  value       = aws_eks_fargate_profile.main.id
}

output "fargate_profile_arn" {
  description = "ARN of the Fargate profile"
  value       = aws_eks_fargate_profile.main.arn
}

#------------------------------------------------------------------------------
# OIDC Provider Outputs
#------------------------------------------------------------------------------

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider"
  value       = aws_iam_openid_connect_provider.this.arn
}

output "oidc_provider_url" {
  description = "The URL of the OIDC Provider (without https://)"
  value       = replace(aws_iam_openid_connect_provider.this.url, "https://", "")
}
