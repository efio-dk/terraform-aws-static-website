#tfsec:ignore:aws-s3-enable-bucket-logging
#tfsec:ignore:aws-s3-specify-public-access-block
#tfsec:ignore:aws-s3-block-public-acls
#tfsec:ignore:aws-s3-no-public-buckets
#tfsec:ignore:aws-s3-ignore-public-acls
#tfsec:ignore:aws-s3-block-public-policy
resource "aws_s3_bucket" "access_logs" {
  count  = var.byo_logs_bucket != null ? 0 : 1
  bucket = local.access_logs_bucket
  acl    = "log-delivery-write"

  versioning {
    enabled = var.enable_access_logs_versioning
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "aws/s3"
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

data "aws_iam_policy_document" "access_logs_bucket_policy" {
  statement {
    actions   = ["s3:PutObject"]
    resources = [format("%s/*", one(aws_s3_bucket.access_logs[*].arn))]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.this.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "access_logs" {
  count  = var.byo_logs_bucket != null ? 0 : 1
  bucket = one(aws_s3_bucket.access_logs[*].id)
  policy = data.aws_iam_policy_document.bucket_policy.json
}

resource "aws_s3_bucket_public_access_block" "access_logs" {
  bucket              = one(aws_s3_bucket.access_logs[*].id)
  block_public_acls   = true
  block_public_policy = true
}
