resource "aws_s3_bucket" "lb_logs" {
  bucket = "magische-${var.environment}-${var.service}-cloudfont-logs"

  tags = {
    Name    = "magische-${var.environment}-${var.service}-cloudfont-logs"
    Service = var.service
    Env     = var.environment
  }
}

resource "aws_s3_bucket_ownership_controls" "lb_logs" {
  bucket = aws_s3_bucket.lb_logs.bucket

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# https://hisuiblog.com/error-aws-terraform-cloudfront-access-log-s3-enable-acl/
resource "aws_s3_bucket_acl" "lb_logs" {
  bucket = aws_s3_bucket.lb_logs.bucket

  acl = "private"
}
