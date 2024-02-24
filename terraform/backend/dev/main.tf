module "base" {
  source = "../base"

  environment = "dev"
  service     = "backend"

  vpc_id = "vpc-076d437cc0fe6e406"

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

  server_ecs_config = {
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
