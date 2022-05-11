resource "aws_iam_policy" "deploy" {
  name        = format("deploy-to-%s", local.site_name)
  path        = var.iam_policy_path
  description = format("grants permissions for deploying to %s", local.site_name)
  policy      = data.aws_iam_policy_document.deploy.json
}

data "aws_iam_policy_document" "deploy" {
  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]

    resources = [
      format("%s/*", aws_s3_bucket.website_content.arn),
    ]
  }

  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.website_content.arn,
    ]
  }

  statement {
    actions = [
      "cloudfront:CreateInvalidation",
    ]

    resources = [
      aws_cloudfront_distribution.this.arn,
      format("%s/*", aws_cloudfront_distribution.this.arn),
    ]
  }
}
