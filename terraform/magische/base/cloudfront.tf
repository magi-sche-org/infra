resource "aws_cloudfront_distribution" "api" {
  origin {
    domain_name = var.api_lb_config.lb_dns_name
    origin_id   = "magische-${var.env}-api-server"

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
    bucket          = aws_s3_bucket.lb_logs.bucket_domain_name
    include_cookies = false
    prefix          = "api/"
  }
  # default_root_object = "index.html"

  aliases = [var.api_domain]

  default_cache_behavior {
    allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = "magische-${var.env}-api-server"
    cache_policy_id          = aws_cloudfront_cache_policy.api.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.api.id

    viewer_protocol_policy = "redirect-to-https"
  }

  viewer_certificate {
    acm_certificate_arn = var.api_cloudfront_config.acm_certificate_arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  tags = {
    Name = "magische-${var.env}-cloudfront"
    Env  = "${var.env}"
  }
}

resource "aws_cloudfront_cache_policy" "api" {
  name        = "magische-${var.env}-api"
  comment     = "magische-${var.env}-api"
  default_ttl = var.api_cloudfront_config.default_ttl
  min_ttl     = var.api_cloudfront_config.min_ttl
  max_ttl     = var.api_cloudfront_config.max_ttl

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

resource "aws_cloudfront_origin_request_policy" "api" {
  name    = "magische-${var.env}-api"
  comment = "magische-${var.env}-api"
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

resource "aws_cloudfront_distribution" "webfront" {
  origin {
    domain_name = var.webfront_lb_config.lb_dns_name
    origin_id   = "magische-${var.env}-webfront-server"

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
    bucket          = aws_s3_bucket.lb_logs.bucket_domain_name
    include_cookies = false
    prefix          = "webfront/"
  }
  # default_root_object = "index.html"

  aliases = [var.webfront_domain]

  default_cache_behavior {
    allowed_methods          = ["GET", "HEAD"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = "magische-${var.env}-webfront-server"
    cache_policy_id          = aws_cloudfront_cache_policy.webfront.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.webfront.id

    viewer_protocol_policy = "redirect-to-https"
  }

  # ordered_cache_behavior {
  #   path_pattern             = "*"
  #   target_origin_id         = "magische-${var.env}-webfront-server"
  #   allowed_methods          = ["GET", "HEAD"]
  #   cached_methods           = ["GET", "HEAD"]
  #   cache_policy_id          = aws_cloudfront_cache_policy.webfront.id
  #   origin_request_policy_id = aws_cloudfront_origin_request_policy.webfront.id
  #   viewer_protocol_policy   = "redirect-to-https"
  #   min_ttl                  = 0
  #   default_ttl              = 3600
  #   max_ttl                  = 86400

  # }

  viewer_certificate {
    acm_certificate_arn = var.api_cloudfront_config.acm_certificate_arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  tags = {
    Name = "magische-${var.env}-cloudfront"
    Env  = "${var.env}"
  }
}

resource "aws_cloudfront_cache_policy" "webfront" {
  name        = "magische-${var.env}-webfront"
  comment     = "magische-${var.env}-webfront"
  min_ttl     = var.webfront_cloudfront_config.min_ttl
  default_ttl = var.webfront_cloudfront_config.default_ttl
  max_ttl     = var.webfront_cloudfront_config.max_ttl

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

resource "aws_cloudfront_origin_request_policy" "webfront" {
  name    = "magische-${var.env}-webfront"
  comment = "magische-${var.env}-webfront"
  headers_config {
    header_behavior = "whitelist"
    headers {
      items = ["Host"]

    }
  }
  cookies_config {
    cookie_behavior = "none"
  }
  query_strings_config {
    query_string_behavior = "all"
  }
}
