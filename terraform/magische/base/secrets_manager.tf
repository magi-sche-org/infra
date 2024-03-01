resource "aws_secretsmanager_secret" "api_server" {
  name       = "magische-${var.env}-api-server"
  kms_key_id = aws_kms_key.main.arn
  tags = {
    Name = "magische-${var.env}-api-server"
  }
}

resource "aws_secretsmanager_secret_version" "api_server" {
  secret_id = aws_secretsmanager_secret.api_server.id
  secret_string = jsonencode({
    # api_secret_key = "please-change-me"
  })
}

output "api_server_ssm_arn" {
  value = aws_secretsmanager_secret.api_server.arn
}
