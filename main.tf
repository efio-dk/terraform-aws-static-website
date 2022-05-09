terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  # Cloudfront relies on the certificate being present in region "us-east-1"
  # If you override this provider, make sure you also set; region = "us-east-1"
  alias  = "us_east_1"
  region = "us-east-1"
}

locals {
  s3_origin_id              = format("%sS3origin", replace(var.domain_name, ".", ""))
  site_name                 = coalesce(var.site_name_override, format("%s-website", var.domain_name))
  website_bucket            = coalesce(var.website_content_bucket_name_override, format("%s-content", local.site_name))
  access_logs_bucket        = coalesce(var.access_logs_bucket_name_override, format("%s-access-logs", local.site_name))
  cloudfront_origin_comment = coalesce(var.cf_origin_comment_override, format("%s website", var.domain_name))
  waf_name                  = coalesce(var.waf_name_override, replace(local.site_name, ".", ""))
  waf_description           = coalesce(var.waf_description_override, format("%s website", var.domain_name))

  tags = merge({
    Terraform-module = "efio-dk/terraform-aws-static-website"
    Managed-by       = "Terraform"
    Terraform        = true
    Domain           = var.domain_name
  }, var.additional_tags)
}
