module "base" {
  source = "../base"

  environment = "dev"
  service     = "backend"

  server_domain   = "api.dev.magi-sche.net"
  route53_zone_id = data.terraform_remote_state.base.outputs.route53_magische_net_zone_id

  vpc_id = data.terraform_remote_state.base.outputs.vpc_id

  public_subnet_ids = [
    "subnet-0986ad61091b1f3b2",
    "subnet-08da485f0b2da6e19",
    "subnet-08da485f0b2da6e19",
  ]
  private_subnet_ids = [
    "subnet-082e05c171793d1c9",
    "subnet-000c773bc77ef47c7",
    "subnet-0e1ce1d78f701dd6d",
  ]
  lb_arn                       = data.terraform_remote_state.base.outputs.lb_arn
  lb_dns_name                  = data.terraform_remote_state.base.outputs.lb_dns_name
  lb_security_group_id         = data.terraform_remote_state.base.outputs.lb_security_group_id
  lb_listener_arn              = data.terraform_remote_state.base.outputs.lb_listener_arn
  lb_listener_rule_priority    = 3000
  acm_certificate_tokyo_arn    = data.terraform_remote_state.base.outputs.acm_certificate_tokyo_arn
  acm_certificate_virginia_arn = data.terraform_remote_state.base.outputs.acm_certificate_virginia_arn

  server_ecs_config = {
    container_port = 80
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
      fargate_weight      = 0
      fargate_spot_base   = 0
      fargate_spot_weight = 1
    }
  }
}
