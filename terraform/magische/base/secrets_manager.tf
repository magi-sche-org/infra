resource "aws_secretsmanager_secret" "api_secret" {
  name       = "magische-${var.env}-api-secret"
  kms_key_id = aws_kms_key.main.arn
  tags = {
    Name = "magische-${var.env}-api-secret"
  }
}

resource "aws_secretsmanager_secret_version" "api_secret_key" {
  secret_id = aws_secretsmanager_secret.api_secret_key.id
  secret_string = jsonencode({
    # api_secret_key = "please-change-me"
  })
}

output "api_secret_key_arn" {
  value = aws_secretsmanager_secret.api_secret_key.arn
}
