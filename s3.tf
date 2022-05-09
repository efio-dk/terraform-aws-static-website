#tfsec:ignore:aws-s3-enable-bucket-logging
#tfsec:ignore:aws-s3-enable-bucket-encryption
#tfsec:ignore:aws-s3-encryption-customer-key
#tfsec:ignore:aws-s3-no-public-access-with-acl
resource "aws_s3_bucket" "website_content" {
  bucket = local.website_bucket
  acl    = "public-read"

  website {
    index_document = var.index_document
    error_document = var.error_document
  }

  versioning {
    enabled = var.enable_website_content_versioning
  }

  dynamic "logging" {
    for_each = var.enable_s3_access_logs ? [1] : []
    content {
      target_bucket = coalesce(var.byo_logs_bucket, one(aws_s3_bucket.access_logs[*].id))
      target_prefix = coalesce(var.s3_access_logs_prefix, format("s3/%s", local.site_name))
    }
  }

  tags = local.tags
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = [format("%s/*", aws_s3_bucket.website_content.arn)]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.this.iam_arn]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.website_content.arn]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.this.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudfront_read_policy" {
  bucket = aws_s3_bucket.website_content.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}

#tfsec:ignore:aws-s3-no-public-buckets tfsec:ignore:aws-s3-ignore-public-acls
resource "aws_s3_bucket_public_access_block" "website_content" {
  bucket = aws_s3_bucket.website_content.id

  #tfsec:ignore:aws-s3-block-public-acls
  block_public_acls = false
  #tfsec:ignore:aws-s3-block-public-policy
  block_public_policy = false
}
