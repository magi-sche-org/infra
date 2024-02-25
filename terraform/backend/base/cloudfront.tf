resource "aws_cloudfront_distribution" "main" {
  origin {
    domain_name = var.lb_dns_name
    origin_id   = "magische-${var.environment}-${var.service}-server-lb"

    # cloudfront->lbもhttpsで通信する
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled         = true
  is_ipv6_enabled = true
  http_version    = "http2and3"

  logging_config {
    bucket          = aws_s3_bucket.lb_logs.bucket
    include_cookies = false
    # prefix = "cloudfront"
  }
  # default_root_object = "index.html"

  aliases = ["example.com", "api.example.com"]

  default_cache_behavior {
    allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = "magische-${var.environment}-${var.service}-server-lb"
    cache_policy_id          = aws_cloudfront_cache_policy.main.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.main.id

    # forwarded_values {
    #   query_string = true
    #   headers      = ["Host"]

    #   cookies {
    #     forward = "none"
    #   }
    # }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  viewer_certificate {
    acm_certificate_arn = var.acm_certificate_virginia_arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  tags = {
    Name    = "magische-${var.environment}-${var.service}-cloudfront"
    Service = "${var.service}"
    Env     = "${var.environment}"
  }
}

resource "aws_cloudfront_cache_policy" "main" {
  name        = "main"
  comment     = "Main cache policy"
  default_ttl = 3600

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

resource "aws_cloudfront_origin_request_policy" "main" {
  name    = "main"
  comment = "Main origin request policy"
  headers_config {
    header_behavior = "allViewer"
  }
  cookies_config {
    cookie_behavior = "all"
  }
  query_strings_config {
    query_string_behavior = "all"
  }
}
