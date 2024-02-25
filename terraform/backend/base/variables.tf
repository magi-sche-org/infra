variable "environment" {
  type = string
}

variable "service" {
  type = string
}

variable "server_domain" {
  type        = string
  description = "The domain name for the server"
}
variable "route53_zone_id" {
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
variable "lb_arn" {
  type = string
}

variable "lb_dns_name" {
  type = string
}

variable "lb_security_group_id" {
  type = string
}

variable "lb_listener_arn" {
  type = string
}

variable "lb_listener_rule_priority" {
  type        = number
  description = "The priority of the listener rule"
}

variable "acm_certificate_tokyo_arn" {
  type = string
}

variable "acm_certificate_virginia_arn" {
  type = string
}

variable "server_ecs_config" {
  type = object({
    container_port = number
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
