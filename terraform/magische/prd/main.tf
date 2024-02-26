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
    listener_rule_priority = 3000
    acm_certificate_arn    = local.acm_certificate_tokyo_arn
  }
  webfront_lb_config = {
    arn                    = local.lb_arn
    lb_dns_name            = local.lb_dns_name
    client_domain_name     = local.webfront_domain
    security_group_id      = local.lb_security_group_id
    listener_arn           = local.lb_listener_arn
    listener_rule_priority = 3100
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
}

output "gha_oidc_deploy_api_role_arn" {
  value = module.base.gha_oidc_deploy_api_role_arn
}
output "gha_oidc_deploy_webfront_role_arn" {
  value = module.base.gha_oidc_deploy_webfront_role_arn
}
