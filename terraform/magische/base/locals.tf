data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  aws_region         = data.aws_region.current.name
  account_id         = data.aws_caller_identity.current.account_id
  rds_admin_username = random_string.rds_admin_username.result
  db_resource_id     = var.rds_config.type == "aurora_mysql_serverless_v2" ? aws_rds_cluster.serverless_v2[0].id : aws_db_instance.mysql_standalone[0].id
}
