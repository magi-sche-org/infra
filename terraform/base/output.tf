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
output "lb_security_group_id" {
  value = aws_security_group.lb.id
}
output "acm_certificate_tokyo_arn" {
  value = aws_acm_certificate.magische_net_tokyo.arn
}
output "acm_certificate_virginia_arn" {
  value = aws_acm_certificate.magische_net_virginia.arn
}
