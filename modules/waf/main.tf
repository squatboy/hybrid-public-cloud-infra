#------------------------------------------------------------------------------
# WAF Module - AWS WAF (Web Application Firewall) Configuration
# ALB 앞단에서 Layer 7 공격을 차단하는 WAF 설정
#------------------------------------------------------------------------------

resource "aws_wafv2_web_acl" "this" {
  name        = "${var.env_name}-web-acl"
  description = "WAF for Hybrid PII Service ALB"
  scope       = "REGIONAL" # ALB용은 REGIONAL, CloudFront용은 CLOUDFRONT

  default_action {
    allow {} # 기본적으로 허용하고, 아래 규칙에 걸리면 차단
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.env_name}-waf-metrics"
    sampled_requests_enabled   = true
  }

  # AWS 공통 규칙 (OWASP Top 10 등)
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 10

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-CommonRules"
      sampled_requests_enabled   = true
    }
  }

  # 알려진 악성 입력 차단 (로그에 보인 .ssh, .aws 등 차단)
  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 20

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-BadInputs"
      sampled_requests_enabled   = true
    }
  }

  # 리눅스 관련 취약점 차단 (LFI 등)
  rule {
    name     = "AWS-AWSManagedRulesLinuxRuleSet"
    priority = 30

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-LinuxRules"
      sampled_requests_enabled   = true
    }
  }

  # AWS IP 평판 리스트 (악성 봇넷 차단)
  rule {
    name     = "AWS-AWSManagedRulesAmazonIpReputationList"
    priority = 40

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-IPReputation"
      sampled_requests_enabled   = true
    }
  }

  tags = var.tags
}

# WAF를 ALB에 연결
resource "aws_wafv2_web_acl_association" "alb_assoc" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}
