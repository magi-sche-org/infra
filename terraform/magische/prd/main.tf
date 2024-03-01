locals {
  public_subnet_ids = [
    data.terraform_remote_state.base.outputs.public_subnet_1a_id,
    data.terraform_remote_state.base.outputs.public_subnet_1c_id,
    data.terraform_remote_state.base.outputs.public_subnet_1d_id,
  ]
  private_subnet_ids = [
    data.terraform_remote_state.base.outputs.private_subnet_1a_id,
    data.terraform_remote_state.base.outputs.private_subnet_1c_id,
    data.terraform_remote_state.base.outputs.private_subnet_1d_id,
  ]
  availability_zones           = data.terraform_remote_state.base.outputs.vpc_availability_zones
  acm_certificate_tokyo_arn    = data.terraform_remote_state.base.outputs.prd_acm_certificate_tokyo_arn
  acm_certificate_virginia_arn = data.terraform_remote_state.base.outputs.prd_acm_certificate_virginia_arn
  route53_zone_id              = data.terraform_remote_state.base.outputs.prd_route53_zone_id
  api_domain                   = "api.magi-sche.net"
  webfront_domain              = "magi-sche.net"

  lb_arn                    = data.terraform_remote_state.base.outputs.lb_arn
  lb_dns_name               = data.terraform_remote_state.base.outputs.lb_dns_name
  lb_security_group_id      = data.terraform_remote_state.base.outputs.lb_security_group_id
  lb_listener_arn           = data.terraform_remote_state.base.outputs.lb_listener_arn
  lb_listener_rule_priority = 3000
}
module "base" {
  source = "../base"

  env = "prd"

  gha_oidc = {
    provider_arn = data.terraform_remote_state.base.outputs.gha_oidc_provider_arn
    branch_name  = "main"
  }
  ecspresso_exec_policy_arn = data.terraform_remote_state.base.outputs.ecspresso_exec_policy_arn


  api_domain      = local.api_domain
  webfront_domain = local.webfront_domain

  route53_zone_id = local.route53_zone_id

  vpc_id = data.terraform_remote_state.base.outputs.vpc_id

  api_cloudfront_config = {
    acm_certificate_arn = local.acm_certificate_virginia_arn
    min_ttl             = 0
    default_ttl         = 0
    max_ttl             = 0
  }
  webfront_cloudfront_config = {
    acm_certificate_arn = local.acm_certificate_virginia_arn
    min_ttl             = 0
    default_ttl         = 900
    max_ttl             = 3600
  }
  api_lb_config = {
    arn                    = local.lb_arn
    lb_dns_name            = local.lb_dns_name
    client_domain_name     = local.api_domain
    security_group_id      = local.lb_security_group_id
    listener_arn           = local.lb_listener_arn
    listener_rule_priority = 1000
    acm_certificate_arn    = local.acm_certificate_tokyo_arn
  }
  webfront_lb_config = {
    arn                    = local.lb_arn
    lb_dns_name            = local.lb_dns_name
    client_domain_name     = local.webfront_domain
    security_group_id      = local.lb_security_group_id
    listener_arn           = local.lb_listener_arn
    listener_rule_priority = 1100
    acm_certificate_arn    = local.acm_certificate_tokyo_arn
  }


  api_ecs_config = {
    desired_count    = 1
    container_port   = 8080
    host_port        = 8080
    cpu_architecture = "ARM64"
    subnet_ids       = local.public_subnet_ids
    autoscaling = {
      max_capacity              = 4
      min_capacity              = 1
      cpu_target_value          = 80
      cpu_scale_out_cooldown    = 30
      cpu_scale_in_cooldown     = 300
      memory_target_value       = 90
      memory_scale_out_cooldown = 30
      memory_scale_in_cooldown  = 300
    }
    capacity_provider = {
      fargate_base        = 1
      fargate_weight      = 1
      fargate_spot_base   = 0
      fargate_spot_weight = 0
    }
  }
  webfront_ecs_config = {
    desired_count    = 1
    container_port   = 3000
    host_port        = 3000
    cpu_architecture = "ARM64"
    subnet_ids       = local.private_subnet_ids
    autoscaling = {
      max_capacity              = 4
      min_capacity              = 1
      cpu_target_value          = 80
      cpu_scale_out_cooldown    = 30
      cpu_scale_in_cooldown     = 300
      memory_target_value       = 90
      memory_scale_out_cooldown = 30
      memory_scale_in_cooldown  = 300
    }
    capacity_provider = {
      fargate_base        = 1
      fargate_weight      = 1
      fargate_spot_base   = 0
      fargate_spot_weight = 0
    }
  }

  rds_config = {
    family = "aurora-mysql8.0"
    type   = "aurora_mysql_serverless_v2"
    port   = 3306
    # https://docs.aws.amazon.com/AmazonRDS/latest/AuroraMySQLReleaseNotes/AuroraMySQL.Updates.30Updates.html
    engine_version          = "8.0.mysql_aurora.3.05.2"
    database_name           = "magische"
    availability_zones      = local.availability_zones
    subnet_ids              = local.private_subnet_ids
    replica_number          = 0
    backup_retention_period = 3
    # JSTで03:00-04:00なのでUTCで18:00-19:00
    backup_window = "18:30-19:30"
    # JSTで月曜の02:00-03:00なのでUTCで日曜の17:00-18:00
    maintenance_window = "Sun:17:00-Sun:18:00"
    aurora_serverless_v2 = {
      min_capacity = 0.5
      max_capacity = 1
    }
    mysql_standalone = null
    # mysql_standalone = {
    #   instance_class        = ""
    #   allocated_storage     = 0
    #   max_allocated_storage = 0
    #   storage_type          = ""
    # }
  }
}

output "gha_oidc_deploy_api_role_arn" {
  value = module.base.gha_oidc_deploy_api_role_arn
}
output "gha_oidc_deploy_webfront_role_arn" {
  value = module.base.gha_oidc_deploy_webfront_role_arn
}

output "rds_admin_username" {
  value = module.base.rds_admin_username
}
output "rds_admin_password_secret_arn" {
  value = module.base.rds_admin_password_secret_arn
}
output "rds_endpoint" {
  value = module.base.rds_endpoint
}
output "rds_db_name" {
  value = module.base.rds_db_name
}
output "rds_port" {
  value = module.base.rds_port
}

output "api_secret_key_arn" {
  value = module.base.api_secret_key_arn
}
