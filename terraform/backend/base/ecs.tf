resource "aws_ecs_cluster" "main" {
  name = "magische-${var.environment}-${var.service}"

  tags = {
    Name    = "magische-${var.environment}-${var.service}-ecs-cluster"
    Service = "${var.service}"
    Env     = "${var.environment}"
  }
}
