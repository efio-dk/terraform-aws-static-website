variable "domain_name" {
  type        = string
  description = "Domain name, eg. 'efio.dk'"
}

variable "FQDNs" {
  type        = list(string)
  description = "List of FQDNs to serve this site on, eg. '[\"efio.dk\", \"www.efio.dk\", \"careers.efio.dk\"]'"
}

variable "additional_tags" {
  type        = map(any)
  description = "Supply any additional tags. Will be added to all resources"
  default     = {}
}

variable "index_document" {
  type        = string
  description = "Default index document to be served"
  default     = "index.html"
}

variable "error_document" {
  type        = string
  description = "Default document to be served in case of errors (generally 404s)"
  default     = "404.html"
}

variable "enable_website_content_versioning" {
  type        = string
  description = "Enable object versioning on website content bucket"
  default     = true
}

variable "enable_access_logs_versioning" {
  type        = string
  description = "Enable object versioning on access logs bucket"
  default     = true
}

variable "iam_policy_path" {
  type        = string
  description = "path of IAM policy"
  default     = "/"
}

###
# Bring your own...
# Allows you to use pre-provisioned resources
variable "byo_logs_bucket" {
  type        = string
  description = "Providing a bucket name here, will use that for storing access logs, and prevent the module from creating one"
  default     = null
}

variable "byo_certificate_arn" {
  type        = string
  description = "Providing an ACM certificate ARN here, will use that for SSL termination, and prevent the module from creating one"
  default     = null
}

###
# Access logs
variable "enable_s3_access_logs" {
  type        = bool
  description = "Enable access logs on website content S3 bucket"
  default     = false
}

variable "enable_cf_access_logs" {
  type        = bool
  description = "Enable access logs on Cloudfront"
  default     = true
}

variable "cf_access_logs_include_cookies" {
  type        = bool
  description = "Include cookies in Cloudfront access logs"
  default     = false
}

###
# Cloudfront
variable "cf_dist_comment" {
  type        = string
  description = "Comment on the CloudFront distribution"
  default     = null
}

variable "cf_allowed_methods" {
  type        = list(string)
  description = "List of allowed methods on Cloudfront distribution"
  default     = ["GET", "HEAD", "OPTIONS"]
}

variable "cf_cached_methods" {
  type        = list(string)
  description = "List of cached methods on Cloudfront distribution"
  default     = ["GET", "HEAD"]
}

variable "cf_price_class" {
  type        = string
  description = "Cloudfront price class. One of PriceClass_All, PriceClass_200, PriceClass_100"
  default     = "PriceClass_100"
}

variable "cf_origin_comment_override" {
  type        = string
  description = "Provide a custom comment on S3 origin"
  default     = null
}

variable "cf_minimum_tls_proto_version" {
  type        = string
  description = "Minimum TLS protocol version"
  default     = "TLSv1.2_2021"
}

###
# WAF
variable "waf_cloudwatch_metrics_enabled" {
  type        = bool
  description = "Whether the web acl should send metrics to Cloudwatch"
  default     = false
}

variable "waf_sampled_requests_enabled" {
  type        = bool
  description = "Whether WAF should store a sampling of the web requests that match the rules"
  default     = false
}

###
# Naming overrides
variable "access_logs_bucket_name_override" {
  type        = string
  description = "Set this if you wish, or have to, override the name of the access logs bucket."
  default     = null
}

variable "website_content_bucket_name_override" {
  type        = string
  description = "Set this if you wish, or have to, override the name of the website content bucket."
  default     = null
}

variable "site_name_override" {
  type        = string
  description = "Provide a custom sitename. Will be used in resource naming. Leaving this empty will give a default value of '<var.domain_name>-website'"
  default     = null
}

variable "waf_name_override" {
  type        = string
  description = "Provide a custom WAF name. Leaving this empty will give a default value of '<var.domain_name>-website'"
  default     = null
}

variable "waf_description_override" {
  type        = string
  description = "Provide a custom WAF description. Leaving this empty will give a default value of '<var.domain_name> website'"
  default     = null
}
