# https://zenn.dev/link/comments/0c7f9f08c940a6
terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws, aws.virginia]
    }
  }
}

variable "zone_id" {
  type = string
}
variable "domain_name" {
  type = string
}
variable "subject_alternative_names" {
  type = list(string)
}
output "acm_certificate_tokyo_arn" {
  value = aws_acm_certificate.tokyo.arn
}
output "acm_certificate_virginia_arn" {
  value = aws_acm_certificate.virginia.arn
}


resource "aws_acm_certificate" "tokyo" {
  domain_name               = var.domain_name
  validation_method         = "DNS"
  subject_alternative_names = var.subject_alternative_names

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.domain_name}-certificate-tokyo"
  }
}

resource "aws_acm_certificate" "virginia" {
  provider                  = aws.virginia
  domain_name               = var.domain_name
  validation_method         = "DNS"
  subject_alternative_names = var.subject_alternative_names

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.domain_name}-certificate-virginia"
  }
}


# https://hisuiblog.com/terraform-acm-wild-card-dns-auth-error/
resource "aws_route53_record" "cert_validation_tokyo" {
  for_each = {
    for dvo in aws_acm_certificate.tokyo.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      type    = dvo.resource_record_type
      zone_id = var.zone_id
      record  = dvo.resource_record_value
    }
  }

  zone_id         = each.value.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
  allow_overwrite = true
}

resource "aws_route53_record" "cert_validation_virginia" {
  provider = aws.virginia
  for_each = {
    for dvo in aws_acm_certificate.virginia.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      type    = dvo.resource_record_type
      zone_id = var.zone_id
      record  = dvo.resource_record_value
    }
  }

  zone_id         = each.value.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "magische_net_tokyo" {
  certificate_arn         = aws_acm_certificate.tokyo.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation_tokyo : record.fqdn]
}

resource "aws_acm_certificate_validation" "magische_net_virginia" {
  provider                = aws.virginia
  certificate_arn         = aws_acm_certificate.virginia.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation_virginia : record.fqdn]
}

