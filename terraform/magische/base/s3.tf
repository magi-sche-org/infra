resource "aws_s3_bucket" "lb_logs" {
  bucket = "magische-${var.env}-cloudfont-logs"

  tags = {
    Name = "magische-${var.env}-cloudfont-logs"
    Env  = var.env
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
  bucket = aws_s3_bucket.lb_logs.id

  acl = "private"
}
