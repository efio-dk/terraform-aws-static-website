#tfsec:ignore:aws-cloudfront-enable-logging
resource "aws_cloudfront_distribution" "this" {
  origin {
    domain_name = aws_s3_bucket.website_content.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  price_class         = var.cf_price_class
  comment             = coalesce(var.cf_dist_comment, local.site_name)
  default_root_object = var.index_document
  aliases             = var.FQDNs
  web_acl_id          = aws_wafv2_web_acl.this.arn

  dynamic "logging_config" {
    for_each = compact([var.byo_logs_bucket])
    content {
      include_cookies = var.cf_access_logs_include_cookies
      bucket          = coalesce(var.byo_logs_bucket, one(aws_s3_bucket.access_logs[*].id))
      prefix          = coalesce(var.cf_access_logs_prefix, format("cloudfront/%s", local.site_name))
    }
  }

  default_cache_behavior {
    allowed_methods  = var.cf_allowed_methods
    cached_methods   = var.cf_cached_methods
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400  # 24 hours
    max_ttl                = 604800 # 7 days

    dynamic "function_association" {
      for_each = compact([local.cf_function_arn])
      content {
        event_type   = var.cf_default_function_event
        function_arn = local.cf_function_arn
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = coalesce(var.byo_certificate_arn, one(aws_acm_certificate.this[*].arn))
    ssl_support_method       = "sni-only"
    minimum_protocol_version = var.cf_minimum_tls_proto_version
  }

  tags = local.tags
}

resource "aws_cloudfront_origin_access_identity" "this" {
  comment = coalesce(var.cf_origin_comment_override, local.cloudfront_origin_comment)
}

resource "aws_cloudfront_function" "url_rewrite" {
  name    = format("%s-add-index-to-uri", local.site_name)
  runtime = "cloudfront-js-1.0"
  comment = "Add '/index.html' to URI if it is missing"
  publish = var.cf_enable_default_behavior_func && var.byo_cf_function_arn == null
  code    = file("${path.module}/functions/url-rewrite.js")

  lifecycle {
    create_before_destroy = true
  }
}
