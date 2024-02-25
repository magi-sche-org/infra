output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_1a_id" {
  value = aws_subnet.public_1a.id
}

output "public_subnet_1c_id" {
  value = aws_subnet.public_1c.id
}

output "public_subnet_1d_id" {
  value = aws_subnet.public_1d.id
}

output "private_subnet_1a_id" {
  value = aws_subnet.private_1a.id
}

output "private_subnet_1c_id" {
  value = aws_subnet.private_1c.id
}

output "private_subnet_1d_id" {
  value = aws_subnet.private_1d.id
}
output "lb_arn" {
  value = aws_lb.main.arn
}
output "lb_listener_arn" {
  value = aws_lb_listener.main.arn
}
output "lb_dns_name" {
  value = aws_lb.main.dns_name
}
output "lb_security_group_id" {
  value = aws_security_group.lb.id
}
# 同じドメインの時は同じzone_idを使う
output "dev_route53_zone_id" {
  value = aws_route53_zone.magische_net.id
}
output "prd_route53_zone_id" {
  value = aws_route53_zone.magische_net.id
}

# 一つしか作れないlistenerに関連付ける必要があり，baseで作成するしかない
output "dev_acm_certificate_tokyo_arn" {
  value = module.dev_acm.acm_certificate_tokyo_arn
}
output "dev_acm_certificate_virginia_arn" {
  value = module.dev_acm.acm_certificate_virginia_arn
}
output "prd_acm_certificate_tokyo_arn" {
  value = module.prd_acm.acm_certificate_tokyo_arn
}
output "prd_acm_certificate_virginia_arn" {
  value = module.prd_acm.acm_certificate_virginia_arn
}


# oidc
output "gha_oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.gha.arn
}

output "ecspresso_exec_policy_arn" {
  value = aws_iam_policy.ecspresso_exec.arn
}
