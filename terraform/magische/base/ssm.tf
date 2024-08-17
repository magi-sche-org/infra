resource "aws_ssm_parameter" "rds_api_username" {
  name   = "/magische/${var.env}/rds_api_username"
  type   = "SecureString"
  value  = "api_user"
  key_id = aws_kms_key.main.arn

  tags = {
    Env = var.env
  }
}

output "db_api_username_ssm_arn" {
  value = aws_ssm_parameter.db_api_username.arn
}
