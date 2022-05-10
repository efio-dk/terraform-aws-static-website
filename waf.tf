# TODO :: configurable WAF rules in the making
resource "aws_wafv2_web_acl" "this" {
  provider    = aws.us_east_1
  name        = local.waf_name
  description = local.waf_description
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = var.waf_cloudwatch_metrics_enabled
    metric_name                = local.waf_name
    sampled_requests_enabled   = var.waf_sampled_requests_enabled
  }

  tags = local.tags
}
