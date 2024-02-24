resource "aws_security_group" "server" {
  name   = "magische-${var.environment}-${var.service}-server"
  vpc_id = var.vpc_id

  tags = {
    Name = "magische-${var.environment}-${var.service}-server"
  }
}

# allow egress
resource "aws_security_group_rule" "server_egress_ipv4" {
  security_group_id = aws_security_group.server.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "server_egress_ipv6" {
  security_group_id = aws_security_group.server.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  ipv6_cidr_blocks  = ["::/0"]
}
