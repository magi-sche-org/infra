# https://thaim.hatenablog.jp/entry/2021/01/11/004738
resource "aws_lb_target_group" "api" {
  name        = "magische-${var.env}-api-${substr(uuid(), 0, 6)}"
  port        = var.api_ecs_config.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/health"
    # path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }

  tags = {
    Name    = "magische-${var.env}-api-server-tg"
    Service = "api"
    Env     = "${var.env}"
  }
}

resource "aws_lb_listener_rule" "api" {
  listener_arn = var.api_lb_config.listener_arn
  priority     = var.api_lb_config.listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }

  condition {
    host_header {
      values = [var.api_lb_config.client_domain_name]
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# https://thaim.hatenablog.jp/entry/2021/01/11/004738
resource "aws_lb_target_group" "webfront" {
  name        = "magische-${var.env}-webfront-${substr(uuid(), 0, 6)}"
  port        = var.webfront_ecs_config.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/api/healthz"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }

  tags = {
    Name    = "magische-${var.env}-webfront-server-tg"
    Service = "webfront"
    Env     = "${var.env}"
  }
}

resource "aws_lb_listener_rule" "webfront" {
  listener_arn = var.webfront_lb_config.listener_arn
  priority     = var.webfront_lb_config.listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webfront.arn
  }

  condition {
    host_header {
      values = [var.webfront_lb_config.client_domain_name]
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
