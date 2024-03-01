# ecs api server
resource "aws_security_group" "api_server" {
  name   = "magische-${var.env}-api-server"
  vpc_id = var.vpc_id

  tags = {
    Name = "magische-${var.env}-api-server"
  }
}
# allow ingress
resource "aws_security_group_rule" "api_server_ingress_from_lb" {
  security_group_id        = aws_security_group.api_server.id
  type                     = "ingress"
  from_port                = var.api_ecs_config.container_port
  to_port                  = var.api_ecs_config.container_port
  protocol                 = "tcp"
  source_security_group_id = var.api_lb_config.security_group_id
}
# allow egress
resource "aws_security_group_rule" "api_server_egress_ipv4_any" {
  security_group_id = aws_security_group.api_server.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "api_server_egress_ipv6_any" {
  security_group_id = aws_security_group.api_server.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  ipv6_cidr_blocks  = ["::/0"]
}


# ecs webfront server
resource "aws_security_group" "webfront_server" {
  name   = "magische-${var.env}-webfront-server"
  vpc_id = var.vpc_id

  tags = {
    Name = "magische-${var.env}-webfront-server"
  }
}
# allow ingress
resource "aws_security_group_rule" "webfront_server_ingress_from_lb" {
  security_group_id        = aws_security_group.webfront_server.id
  type                     = "ingress"
  from_port                = var.webfront_ecs_config.container_port
  to_port                  = var.webfront_ecs_config.container_port
  protocol                 = "tcp"
  source_security_group_id = var.webfront_lb_config.security_group_id
}
# allow egress
resource "aws_security_group_rule" "webfront_server_egress_ipv4_any" {
  security_group_id = aws_security_group.webfront_server.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "webfront_server_egress_ipv6_any" {
  security_group_id = aws_security_group.webfront_server.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  ipv6_cidr_blocks  = ["::/0"]
}




# lb(security_group_id = var.lb_security_group_id)
# egress to ecs (lb -> api server)
resource "aws_security_group_rule" "lb_egress_api_server" {
  security_group_id        = var.api_lb_config.security_group_id
  type                     = "egress"
  from_port                = var.api_ecs_config.container_port
  to_port                  = var.api_ecs_config.container_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.api_server.id
}
# egress to ecs (lb -> webfront server)
resource "aws_security_group_rule" "lb_egress_webfront_server" {
  security_group_id        = var.webfront_lb_config.security_group_id
  type                     = "egress"
  from_port                = var.webfront_ecs_config.container_port
  to_port                  = var.webfront_ecs_config.container_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.webfront_server.id
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

# rds
resource "aws_security_group" "rds" {
  name   = "magische-${var.env}-rds"
  vpc_id = var.vpc_id

  tags = {
    Name = "magische-${var.env}-rds"
  }
}
# allow ingress from api server
resource "aws_security_group_rule" "rds_ingress_api_server" {
  security_group_id        = aws_security_group.rds.id
  type                     = "ingress"
  from_port                = var.rds_config.port
  to_port                  = var.rds_config.port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.api_server.id
}

# bastion
resource "aws_security_group" "bastion" {
  name   = "magische-${var.env}-bastion"
  vpc_id = var.vpc_id

  tags = {
    Name = "magische-${var.env}-bastion"
  }
}

# allow ingress(22)
resource "aws_security_group_rule" "bastion_ingress_ipv4" {
  security_group_id = aws_security_group.bastion.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "bastion_ingress_ipv6" {
  security_group_id = aws_security_group.bastion.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  ipv6_cidr_blocks  = ["::/0"]
}

# allow egress
resource "aws_security_group_rule" "bastion_egress_ipv4_any" {
  security_group_id = aws_security_group.bastion.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "bastion_egress_ipv6_any" {
  security_group_id = aws_security_group.bastion.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "rds_ingress_bastion" {
  security_group_id        = aws_security_group.rds.id
  type                     = "ingress"
  from_port                = var.rds_config.port
  to_port                  = var.rds_config.port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
}
