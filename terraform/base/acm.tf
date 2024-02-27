# resource "aws_acm_certificate" "magische_net_tokyo" {
#   domain_name       = "magi-sche.net"
#   validation_method = "DNS"
#   subject_alternative_names = [
#     "*.magi-sche.net",
#   ]

#   lifecycle {
#     create_before_destroy = true
#   }

#   tags = {
#     Name = "magi-sche.net-certificate-tokyo"
#   }
# }

# resource "aws_acm_certificate" "magische_net_virginia" {
#   provider          = aws.virginia
#   domain_name       = "magi-sche.net"
#   validation_method = "DNS"
#   subject_alternative_names = [
#     "*.magi-sche.net",
#   ]

#   lifecycle {
#     create_before_destroy = true
#   }

#   tags = {
#     Name = "magi-sche.net-certificate-virginia"
#   }
# }

# locals {
#   zone_id = aws_route53_zone.magische_net.zone_id
# }

# # https://hisuiblog.com/terraform-acm-wild-card-dns-auth-error/
# resource "aws_route53_record" "cert_validation_tokyo" {
#   for_each = {
#     for dvo in aws_acm_certificate.magische_net_tokyo.domain_validation_options : dvo.domain_name => {
#       name    = dvo.resource_record_name
#       type    = dvo.resource_record_type
#       zone_id = local.zone_id
#       record  = dvo.resource_record_value
#     }
#   }

#   zone_id         = each.value.zone_id
#   name            = each.value.name
#   type            = each.value.type
#   records         = [each.value.record]
#   ttl             = 60
#   allow_overwrite = true
# }

# resource "aws_route53_record" "cert_validation_virginia" {
#   provider = aws.virginia
#   for_each = {
#     for dvo in aws_acm_certificate.magische_net_virginia.domain_validation_options : dvo.domain_name => {
#       name    = dvo.resource_record_name
#       type    = dvo.resource_record_type
#       zone_id = local.zone_id
#       record  = dvo.resource_record_value
#     }
#   }

#   zone_id         = each.value.zone_id
#   name            = each.value.name
#   type            = each.value.type
#   records         = [each.value.record]
#   ttl             = 60
#   allow_overwrite = true
# }

# resource "aws_acm_certificate_validation" "magische_net_tokyo" {
#   certificate_arn         = aws_acm_certificate.magische_net_tokyo.arn
#   validation_record_fqdns = [for record in aws_route53_record.cert_validation_tokyo : record.fqdn]
# }

# resource "aws_acm_certificate_validation" "magische_net_virginia" {
#   provider                = aws.virginia
#   certificate_arn         = aws_acm_certificate.magische_net_virginia.arn
#   validation_record_fqdns = [for record in aws_route53_record.cert_validation_virginia : record.fqdn]
# }

module "dev_acm" {
  source = "./modules/acm"

  zone_id     = aws_route53_zone.magische_net.zone_id
  domain_name = "dev.magi-sche.org"
  subject_alternative_names = [
    "*.dev.magi-sche.org",
  ]

  providers = {
    aws          = aws
    aws.virginia = aws.virginia
  }
}

module "prd_acm" {
  source = "./modules/acm"

  zone_id     = aws_route53_zone.magische_net.zone_id
  domain_name = "magi-sche.net"
  subject_alternative_names = [
    "*.magi-sche.net",
  ]

  providers = {
    aws          = aws
    aws.virginia = aws.virginia
  }
}
