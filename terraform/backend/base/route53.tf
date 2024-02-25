

resource "aws_route53_record" "server" {
  zone_id = var.route53_zone_id
  name    = var.server_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = false
  }
}
