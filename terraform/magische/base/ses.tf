resource "aws_ses_domain_identity" "main" {
  domain = var.webfront_domain
}

resource "aws_ses_domain_identity_verification" "main" {
  domain = aws_ses_domain_identity.main.domain
}
