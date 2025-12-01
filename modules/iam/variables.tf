#------------------------------------------------------------------------------
# IAM Module - Variables
#------------------------------------------------------------------------------

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "aws_region" {
  description = "AWS region for ARN construction"
  type        = string
  default     = "ap-northeast-2"
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
