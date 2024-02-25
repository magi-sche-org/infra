resource "aws_cloudwatch_log_group" "api_server" {
  name = "/ecs/magische-${var.env}-api-server"
}
resource "aws_cloudwatch_log_group" "webfront_server" {
  name = "/ecs/magische-${var.env}-webfront-server"
}
