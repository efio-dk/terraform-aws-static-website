# SSL certificate covering all FQDNs
resource "aws_acm_certificate" "this" {
  provider                  = aws.us_east_1
  domain_name               = var.domain_name
  validation_method         = "DNS"
  subject_alternative_names = setsubtract(var.FQDNs, [var.domain_name])

  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

# Domain validation records
resource "aws_route53_record" "validation" {
  for_each = { for option in aws_acm_certificate.this.domain_validation_options : option.domain_name => {
    name   = option.resource_record_name
    record = option.resource_record_value
    type   = option.resource_record_type
  } }

  name    = each.value.name
  records = [each.value.record]
  ttl     = 60
  type    = each.value.type
  zone_id = data.aws_route53_zone.this.zone_id
}

# Wait for domain validation to complete
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}
