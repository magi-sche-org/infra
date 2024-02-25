# resource "aws_lb" "lb" {
#   name                 = "magische-${var.environment}-${var.service}-alb"
#   internal             = false
#   load_balancer_type   = "application"
#   security_groups      = [aws_security_group.lb.id]
#   subnets              = var.public_subnet_ids[*]
#   enable_waf_fail_open = true

#   tags = {
#     Name    = "magische-${var.environment}-${var.service}-alb"
#     Service = "${var.service}"
#     Env     = "${var.environment}"
#   }
# }
resource "aws_lb_target_group" "server" {
  name     = "magische-${var.environment}-${var.service}-tg"
  port     = var.server_ecs_config.container_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    # path                = "/health"
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name    = "magische-${var.environment}-${var.service}-server-tg"
    Service = "${var.service}"
    Env     = "${var.environment}"
  }
}

resource "aws_lb_listener_rule" "server" {
  listener_arn = var.lb_listener_arn
  priority     = var.lb_listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.server.arn
  }

  condition {
    host_header {
      values = [var.server_domain]
    }
  }
}

# resource "aws_lb_listener" "server" {
#   load_balancer_arn = var.lb_arn
#   port              = 443
#   protocol          = "HTTPS"
#   certificate_arn   = var.acm_certificate_tokyo_arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.server.arn
#   }
# }
