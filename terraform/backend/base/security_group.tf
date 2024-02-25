# ecs server
resource "aws_security_group" "server" {
  name   = "magische-${var.environment}-${var.service}-server"
  vpc_id = var.vpc_id

  tags = {
    Name = "magische-${var.environment}-${var.service}-server"
  }
}
# allow ingress
resource "aws_security_group_rule" "server_ingress_from_lb" {
  security_group_id        = aws_security_group.server.id
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = var.lb_security_group_id
}
# allow egress
resource "aws_security_group_rule" "server_egress_ipv4_any" {
  security_group_id = aws_security_group.server.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "server_egress_ipv6_any" {
  security_group_id = aws_security_group.server.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  ipv6_cidr_blocks  = ["::/0"]
}


# lb(security_group_id = var.lb_security_group_id)
# egress to server
resource "aws_security_group_rule" "lb_egress_ipv4" {
  security_group_id        = var.lb_security_group_id
  type                     = "egress"
  from_port                = var.server_ecs_config.container_port
  to_port                  = var.server_ecs_config.container_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.server.id
}

# # allow ingress
# resource "aws_security_group_rule" "lb_ingress_ipv4" {
#   security_group_id = aws_security_group.lb.id
#   type              = "ingress"
#   from_port         = 80
#   to_port           = 80
#   protocol          = "tcp"
#   cidr_blocks       = ["0.0.0.0/0"]
# }

# resource "aws_security_group_rule" "lb_ingress_ipv6" {
#   security_group_id = aws_security_group.lb.id
#   type              = "ingress"
#   from_port         = 80
#   to_port           = 80
#   protocol          = "tcp"
#   ipv6_cidr_blocks  = ["::/0"]
# }

# resource "aws_security_group_rule" "lb_ingress_https_ipv4" {
#   security_group_id = aws_security_group.lb.id
#   type              = "ingress"
#   from_port         = 443
#   to_port           = 443
#   protocol          = "tcp"
#   cidr_blocks       = ["0.0.0.0/0"]
# }

# resource "aws_security_group_rule" "lb_ingress_https_ipv6" {
#   security_group_id = aws_security_group.lb.id
#   type              = "ingress"
#   from_port         = 443
#   to_port           = 443
#   protocol          = "tcp"
#   ipv6_cidr_blocks  = ["::/0"]
# }

# # allow egress
# resource "aws_security_group_rule" "lb_egress_ipv4" {
#   security_group_id        = aws_security_group.lb.id
#   type                     = "egress"
#   from_port                = 0
#   to_port                  = 0
#   protocol                 = "-1"
#   source_security_group_id = aws_security_group.server.id
# }
