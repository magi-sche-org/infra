

resource "aws_route53_record" "api" {
  zone_id = var.route53_zone_id
  name    = var.api_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.api.domain_name
    zone_id                = aws_cloudfront_distribution.api.hosted_zone_id
    evaluate_target_health = false
  }
}


resource "aws_route53_record" "webfront" {
  zone_id = var.route53_zone_id
  name    = var.webfront_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.webfront.domain_name
    zone_id                = aws_cloudfront_distribution.webfront.hosted_zone_id
    evaluate_target_health = false
  }
}
