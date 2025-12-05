# TFLint Configuration
# https://github.com/terraform-linters/tflint/blob/master/docs/configuration.md

config {
  # TFLint 플러그인 활성화
  plugin_dir = "~/.tflint.d/plugins"
  
  call_module_type = "all"
  force = false
  format = "compact"
}

# AWS 플러그인 설정
plugin "aws" {
  enabled = true
  version = "0.27.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
  
  region = "ap-northeast-2"
}

rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_deprecated_index" {
  enabled = true
}

rule "terraform_deprecated_interpolation" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_empty_list_equality" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_standard_module_structure" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_unused_required_providers" {
  enabled = true
}

# AWS 규칙
rule "aws_resource_missing_tags" {
  enabled = true
  tags = ["Name", "Environment", "Owner"]
}

rule "aws_s3_bucket_versioning" {
  enabled = true
}

rule "aws_instance_metadata_options" {
  enabled = true
}
