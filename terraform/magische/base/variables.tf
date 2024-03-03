variable "env" {
  type = string
}

# variable "gha_oidc_provider_arn" {
#   type = string
# }
variable "gha_oidc" {
  type = object({
    provider_arn = string
    branch_name  = string
  })
}
variable "ecspresso_exec_policy_arn" {
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

# variable "vpc_availability_zones" {
#   type = list(string)
# }

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
    # acm_certificate_arn    = string
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
    # acm_certificate_arn    = string
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
    assign_public_ip = bool
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
    assign_public_ip = bool
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

variable "rds_config" {
  type = object({
    type                    = string # mysql_standalone, aurora_mysql_provisioned, aurora_mysql_serverless_v2
    family                  = string # aurora-mysql8.0 / mysql8.0
    port                    = number
    engine_version          = string # 3/1時点，8.0.35 or 8.0.mysql_aurora.3.05.2
    database_name           = string
    subnet_ids              = list(string)
    availability_zones      = list(string)
    replica_number          = number
    backup_retention_period = number
    backup_window           = string
    maintenance_window      = string
    aurora_serverless_v2 = object({
      min_capacity = number
      max_capacity = number
    })
    mysql_standalone = object({
      instance_class        = string # db.t4g.microかな
      allocated_storage     = number
      max_allocated_storage = number
      storage_type          = string
    })
  })
  validation {
    condition     = var.rds_config.type == "mysql_standalone" || var.rds_config.type == "aurora_mysql_serverless_v2" #  || var.rds_config.type == "aurora_mysql_provisioned" #not available
    error_message = "rds_config.type must be mysql_standalone, aurora_mysql_provisioned, or aurora_mysql_serverless"
  }
}
