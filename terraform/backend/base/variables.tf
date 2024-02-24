variable "environment" {
  type = string
}

variable "service" {
  type = string
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID to use for the ECS cluster"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "The public subnet IDs to use for the ECS cluster"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "The private subnet IDs to use for the ECS cluster"
}

variable "server_ecs_config" {
  type = object({
    autoscaling = object({
      max_capacity              = number
      min_capacity              = number
      cpu_target_value          = number
      cpu_scale_out_cooldown    = number
      cpu_scale_in_cooldown     = number
      memory_target_value       = number
      memory_scale_out_cooldown = number
      memory_scale_in_cooldown  = number
    })
    capacity_provider = object({
      fargate_base        = number
      fargate_weight      = number
      fargate_spot_base   = number
      fargate_spot_weight = number
    })
  })
}
