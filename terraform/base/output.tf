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
output "route53_magische_net_zone_id" {
  value = aws_route53_zone.magische_net.id
}
output "lb_arn" {
  value = aws_lb.main.arn
}
output "dev_lb_listener_arn" {
  value = aws_lb_listener.dev.arn
}
output "prd_lb_listener_arn" {
  value = aws_lb_listener.prd.arn
}
output "lb_dns_name" {
  value = aws_lb.main.dns_name
}
output "lb_security_group_id" {
  value = aws_security_group.lb.id
}
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
