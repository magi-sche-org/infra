variable "env" {
  type = string
}

variable "api_domain" {
  type        = string
  description = "The domain name for the server"
}
variable "webfront_domain" {
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


variable "api_cloudfront_config" {
  type = object({
    acm_certificate_arn = string
    min_ttl             = number
    default_ttl         = number
    max_ttl             = number
  })
}

variable "webfront_cloudfront_config" {
  type = object({
    acm_certificate_arn = string
    min_ttl             = number
    default_ttl         = number
    max_ttl             = number
  })
}

# variable "acm_certificate_virginia_arn" {
#   type = string
# }

variable "api_lb_config" {
  type = object({
    arn                    = string
    lb_dns_name            = string
    client_domain_name     = string
    security_group_id      = string
    listener_arn           = string
    listener_rule_priority = number
    acm_certificate_arn    = string
  })
  description = "api server向きのALBのrule設定。domain_nameは受け取るHostヘッダーの中身（CloudFrontから透過して来る）"
}
variable "webfront_lb_config" {
  type = object({
    arn                    = string
    lb_dns_name            = string
    client_domain_name     = string
    security_group_id      = string
    listener_arn           = string
    listener_rule_priority = number
    acm_certificate_arn    = string
  })
  description = "webfront server向きのALBのrule設定。domain_nameは受け取るHostヘッダーの中身（CloudFrontから透過して来る）"
}

variable "api_ecs_config" {
  type = object({
    desired_count    = number
    container_port   = number
    host_port        = number
    cpu_architecture = string
    subnet_ids       = list(string)
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

variable "webfront_ecs_config" {
  type = object({
    desired_count    = number
    container_port   = number
    host_port        = number
    cpu_architecture = string
    subnet_ids       = list(string)
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
