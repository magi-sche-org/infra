resource "aws_security_group" "server" {
  name   = "magische-${var.environment}-${var.service}-server"
  vpc_id = var.vpc_id

  tags = {
    Name = "magische-${var.environment}-${var.service}-server"
  }
}
