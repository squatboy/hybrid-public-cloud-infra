#------------------------------------------------------------------------------
# ECR Module - Variables
#------------------------------------------------------------------------------

variable "repository_names" {
  description = "List of ECR repository names to create"
  type        = list(string)
  default     = ["pii-system/pii-api"]
}

variable "image_tag_mutability" {
  description = "Image tag mutability setting (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

#------------------------------------------------------------------------------
# Lifecycle Policy
#------------------------------------------------------------------------------

variable "enable_lifecycle_policy" {
  description = "Enable ECR lifecycle policy for image cleanup"
  type        = bool
  default     = true
}

variable "max_image_count" {
  description = "Maximum number of tagged images to keep"
  type        = number
  default     = 30
}

variable "untagged_image_days" {
  description = "Days to keep untagged images before deletion"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
