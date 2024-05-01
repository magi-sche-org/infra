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
    secret_key                    = "please-change-me"
    oauth_google_client_id        = "please-change-me"
    oauth_google_client_secret    = "please-change-me"
    oauth_microsoft_client_id     = "please-change-me"
    oauth_microsoft_client_secret = "please-change-me"
  })
  lifecycle {
    ignore_changes = [secret_string]
  }
}

resource "aws_secretsmanager_secret" "db_api_user_password" {
  name       = "magische-${var.env}-db-api-user-password"
  kms_key_id = aws_kms_key.main.arn
  tags = {
    Name = "magische-${var.env}-db-api-user-password"
  }
}

resource "aws_secretsmanager_secret_version" "db_api_user_password" {
  secret_id     = aws_secretsmanager_secret.db_api_user_password.id
  secret_string = "please-change-me"
  lifecycle {
    ignore_changes = [secret_string]
  }
}

output "api_server_ssm_arn" {
  value = aws_secretsmanager_secret.api_server.arn
}
output "db_api_user_password_ssm_arn" {
  value = aws_secretsmanager_secret.db_api_user_password.arn
}
