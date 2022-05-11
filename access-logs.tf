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

resource "aws_s3_bucket_public_access_block" "access_logs" {
  bucket              = one(aws_s3_bucket.access_logs[*].id)
  block_public_acls   = true
  block_public_policy = true
}
