# TODO :: configurable WAF rules in the making
resource "aws_wafv2_web_acl" "this" {
  provider    = aws.us_east_1
  name        = local.waf_name
  description = local.waf_description
  scope       = "CLOUDFRONT"

  default_action {
    dynamic "allow" {
      for_each = var.waf_default_action == "allow" ? [1] : []
      content {}
    }

    dynamic "block" {
      for_each = var.waf_default_action == "block" ? [1] : []
      content {}
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = var.waf_cloudwatch_metrics_enabled
    metric_name                = local.waf_name
    sampled_requests_enabled   = var.waf_sampled_requests_enabled
  }

  lifecycle {
    ignore_changes = [rule]
  }

  tags = local.tags
}
