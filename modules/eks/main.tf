#------------------------------------------------------------------------------
# EKS Module - Main Configuration
# EKS Cluster with Fargate Profile
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# EKS Cluster
#------------------------------------------------------------------------------

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = var.endpoint_public_access
    security_group_ids      = var.security_group_ids
  }

  # CloudWatch Logs for security and audit
  enabled_cluster_log_types = var.enabled_log_types

  tags = merge(var.tags, { Name = var.cluster_name })

  depends_on = [var.cluster_role_arn]
}

#------------------------------------------------------------------------------
# Fargate Profile
#------------------------------------------------------------------------------

resource "aws_eks_fargate_profile" "main" {
  cluster_name           = aws_eks_cluster.this.name
  fargate_profile_name   = "${var.cluster_name}-fargate-profile"
  pod_execution_role_arn = var.fargate_role_arn
  subnet_ids             = var.private_subnet_ids

  # System namespaces
  selector {
    namespace = "kube-system"
  }

  selector {
    namespace = "argocd"
  }

  # Application namespaces
  dynamic "selector" {
    for_each = var.fargate_namespaces
    content {
      namespace = selector.value
    }
  }

  tags = merge(var.tags, { Name = "${var.cluster_name}-fargate-profile" })

  depends_on = [aws_eks_cluster.this]
}

#------------------------------------------------------------------------------
# CoreDNS Patch for Fargate
# Fargate requires CoreDNS to run on Fargate, need to remove ec2 annotation
#------------------------------------------------------------------------------

# Note: After cluster creation, run this command to patch CoreDNS:
# kubectl patch deployment coredns -n kube-system --type json \
#   -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'

#------------------------------------------------------------------------------
# OIDC Provider for IRSA (IAM Roles for Service Accounts)
# Required for AWS Load Balancer Controller and other AWS integrations
#------------------------------------------------------------------------------

# OIDC TLS 인증서 정보 조회
data "tls_certificate" "this" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# IAM OIDC Provider 생성
# 이 리소스가 있어야 EKS Pod가 IRSA를 통해 AWS IAM 권한을 사용할 수 있음
resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.this.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer

  tags = merge(var.tags, { Name = "${var.cluster_name}-oidc-provider" })
}
