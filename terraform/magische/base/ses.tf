resource "aws_ses_domain_identity" "main" {
  domain = var.webfront_domain
}

# resource "aws_ses_domain_identity_verification" "main" {
#   domain = aws_ses_domain_identity.main.domain
# }

# resource "aws_route53_record" "ses_verification" {
#   zone_id = var.route53_zone_id
#   name    = aws_ses_domain_identity_verification.main.id
#   type    = "TXT"
#   ttl     = "60"
#   records = [aws_ses_domain_identity_verification.main.verification_token]
# }
