# -------------------------------
# RDS subnet group 共通
# -------------------------------
resource "aws_db_subnet_group" "main" {
  name       = "magische-${var.env}-subnetgroup"
  subnet_ids = var.rds_config.subnet_ids

  tags = {
    Name = "magische-${var.env}-subnetgroup"
    Env  = var.env
  }
}
resource "random_string" "rds_admin_username" {
  length  = 16
  special = false
}
output "rds_admin_username" {
  value = random_string.rds_admin_username.result
}
output "rds_admin_password_secret_arn" {
  value = var.rds_config.type == "aurora_mysql_serverless_v2" ? aws_rds_cluster.serverless_v2[0].master_user_secret[0].secret_arn : aws_db_instance.mysql_standalone[0].master_user_secret[0].secret_arn
  # value = aws_rds_cluster.serverless_v2.master_user_secret[0].secret_arn
}

output "rds_endpoint" {
  value = var.rds_config.type == "aurora_mysql_serverless_v2" ? aws_rds_cluster.serverless_v2[0].endpoint : aws_db_instance.mysql_standalone[0].endpoint
}
output "rds_db_name" {
  value = var.rds_config.database_name
}





# -------------------------------
# RDS parameter group
# -------------------------------
resource "aws_db_parameter_group" "mysql_standalone" {
  count = var.rds_config.type == "mysql_standalone" ? 1 : 0
  # count  = var.env == "dev" ? 1 : 0
  name   = "magische-${var.env}"
  family = var.rds_config.family
  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_connection"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_filesystem"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_results"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
  tags = {
    Name = "magische-${var.env}"
    Env  = var.env
  }
}

# -------------------------------
# RDS option group
# -------------------------------
resource "aws_db_option_group" "mysql_standalone" {
  count                = var.rds_config.type == "mysql_standalone" ? 1 : 0
  name                 = "magische-${var.env}-mysql-standalone-optiongroup"
  engine_name          = "mysql"
  major_engine_version = "8.0"
}



# # -------------------------------
# # RDS instance
# # -------------------------------

resource "aws_db_instance" "mysql_standalone" {
  count          = var.rds_config.type == "mysql_standalone" ? 1 : 0
  engine         = "mysql"
  engine_version = var.rds_config.engine_version

  identifier = "magische-${var.env}-mysql-standalone"

  username = random_string.rds_admin_username.result

  manage_master_user_password   = true
  master_user_secret_kms_key_id = aws_kms_key.main.arn

  instance_class = var.rds_config.mysql_standalone.instance_class

  allocated_storage     = var.rds_config.mysql_standalone.allocated_storage
  max_allocated_storage = var.rds_config.mysql_standalone.allocated_storage
  storage_type          = var.rds_config.mysql_standalone.storage_type
  storage_encrypted     = true
  kms_key_id            = aws_kms_key.main.arn

  multi_az             = false
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [
    aws_security_group.rds.id,
  ]
  publicly_accessible = false
  port                = var.rds_config.port

  db_name              = var.rds_config.database_name
  parameter_group_name = aws_db_parameter_group.mysql_standalone[0].name
  option_group_name    = aws_db_option_group.mysql_standalone[0].name

  backup_window              = var.rds_config.backup_window
  backup_retention_period    = var.rds_config.backup_retention_period
  maintenance_window         = var.rds_config.maintenance_window
  auto_minor_version_upgrade = false

  deletion_protection = true
  skip_final_snapshot = false

  apply_immediately = true

  tags = {
    Name = "magische-${var.env}-mysql-standalone"
    Env  = var.env
  }
}




# -------------------------------------------------------------------------------
resource "aws_rds_cluster_parameter_group" "serverless_v2" {
  count  = var.rds_config.type == "aurora_mysql_serverless_v2" ? 1 : 0
  name   = "magische-${var.env}"
  family = var.rds_config.family

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_bin"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_connection"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_filesystem"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_results"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
}



// cluster設定
resource "aws_rds_cluster" "serverless_v2" {
  # aurora serverless v2のみ
  count = var.rds_config.type == "aurora_mysql_serverless_v2" ? 1 : 0

  # meta
  cluster_identifier = "magische-${var.env}-aurora-serverless-v2"
  availability_zones = var.rds_config.availability_zones
  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]

  # network
  port                 = var.rds_config.port
  db_subnet_group_name = aws_db_subnet_group.main.name

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.serverless_v2[0].name

  # engine情報
  engine = "aurora-mysql"
  // aurora serverless v2は engine_modeがprovisionedになります
  engine_mode    = "provisioned"
  engine_version = var.rds_config.engine_version



  database_name   = var.rds_config.database_name
  master_username = random_string.rds_admin_username.result
  # master_password                 = var.rds_password
  manage_master_user_password   = true
  master_user_secret_kms_key_id = aws_kms_key.main.arn

  // backtrackは使わない
  backtrack_window = 0


  # backup
  backup_retention_period   = var.rds_config.backup_retention_period
  skip_final_snapshot       = false
  final_snapshot_identifier = "magische-${var.env}-aurora-serverless-v2-final-snapshot"
  preferred_backup_window   = var.rds_config.backup_window

  preferred_maintenance_window = var.rds_config.maintenance_window

  # storage
  storage_encrypted = true
  kms_key_id        = aws_kms_key.main.arn


  // aurora serverless v2のmax/minの容量を設定
  serverlessv2_scaling_configuration {
    min_capacity = var.rds_config.aurora_serverless_v2.min_capacity
    max_capacity = var.rds_config.aurora_serverless_v2.max_capacity
  }

  deletion_protection = true
  apply_immediately   = true

  lifecycle {
    ignore_changes = [
      availability_zones,
    ]
  }

  tags = {
    Name = "magische-${var.env}-aurora-serverless-v2"
    Env  = var.env
  }
}


// rds instanceの設定
resource "aws_rds_cluster_instance" "serverless_v2" {
  count              = var.rds_config.type == "aurora_mysql_serverless_v2" ? var.rds_config.replica_number + 1 : 0
  identifier         = "magische-${var.env}-aurora-serverless-v2-instance-${format("%02d", count.index + 1)}"
  cluster_identifier = aws_rds_cluster.serverless_v2[0].id
  # // instance数を設定
  # count = var.rds_config.replica_number
  // instance数に応じて順次az設定
  availability_zone = var.rds_config.availability_zones[count.index % length(var.rds_config.availability_zones)]

  # engine情報
  engine         = aws_rds_cluster.serverless_v2[0].engine
  engine_version = aws_rds_cluster.serverless_v2[0].engine_version

  // serverlessを指定
  instance_class             = "db.serverless"
  db_subnet_group_name       = aws_rds_cluster.serverless_v2[0].db_subnet_group_name
  db_parameter_group_name    = aws_rds_cluster.serverless_v2[0].db_cluster_parameter_group_name
  publicly_accessible        = false
  auto_minor_version_upgrade = false

  tags = {
    Name = "magische-${var.env}-aurora-serverless-v2-instance-${format("%02d", count.index + 1)}"
    Env  = var.env
  }
}
