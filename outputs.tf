output "deploy_policy_arn" {
  description = "ARN of IAM policy that allows deploying static assets to content bucket, and invalidating cache in Cloudfront. Attach this policy to your CI user"
  value = aws_iam_policy.deploy.arn
}
