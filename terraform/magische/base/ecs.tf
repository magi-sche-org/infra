resource "aws_ecs_cluster" "main" {
  name = "magische-${var.env}"

  tags = {
    Name    = "magische-${var.env}-api-ecs-cluster"
    Service = "api"
    Env     = "${var.env}"
  }
}

resource "aws_ecs_service" "api" {
  name            = "magische-${var.env}-api"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api.arn
  # launch_type     = "FARGATE"
  desired_count = var.api_ecs_config.desired_count
  network_configuration {
    subnets = var.api_ecs_config.subnet_ids
    security_groups = [
      aws_security_group.api_server.id,
    ]
    assign_public_ip = var.api_ecs_config.assign_public_ip
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    base              = var.api_ecs_config.capacity_provider.fargate_base
    weight            = var.api_ecs_config.capacity_provider.fargate_weight
  }
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    base              = var.api_ecs_config.capacity_provider.fargate_spot_base
    weight            = var.api_ecs_config.capacity_provider.fargate_spot_weight
  }
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.api.arn
    container_name   = "magische-${var.env}-api"
    container_port   = var.api_ecs_config.container_port
  }

  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition,
      # network_configuration,
    ]
  }
  tags = {
    Name    = "magische-${var.env}-api-ecs-service"
    Service = "api"
    Env     = "${var.env}"
  }
}

# 実質ダミー
resource "aws_ecs_task_definition" "api" {
  family                   = "magische-${var.env}-api"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.api_server_task_exec.arn
  task_role_arn            = aws_iam_role.api_server_task.arn
  track_latest             = false
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = var.api_ecs_config.cpu_architecture
  }
  container_definitions = jsonencode([
    {
      name  = "magische-${var.env}-api"
      image = "nginx"
      portMappings = [
        {
          containerPort = var.api_ecs_config.container_port
          hostPort      = var.api_ecs_config.host_port
          protocol      = "tcp"
        },
      ]
    },
  ])

  tags = {
    Name    = "magische-${var.env}-api-server"
    Service = "api"
    Env     = "${var.env}"
  }
}

# autoscaling
# https://qiita.com/neruneruo/items/ccdc22aab86d52580173
resource "aws_appautoscaling_target" "api" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.api.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  max_capacity       = var.api_ecs_config.autoscaling.max_capacity
  min_capacity       = var.api_ecs_config.autoscaling.min_capacity
}
resource "aws_appautoscaling_policy" "api_cpu" {
  name               = "magische-${var.env}-api-server-cpu"
  service_namespace  = aws_appautoscaling_target.api.service_namespace
  resource_id        = aws_appautoscaling_target.api.resource_id
  scalable_dimension = aws_appautoscaling_target.api.scalable_dimension
  policy_type        = "TargetTrackingScaling"
  target_tracking_scaling_policy_configuration {
    target_value       = var.api_ecs_config.autoscaling.cpu_target_value
    scale_out_cooldown = var.api_ecs_config.autoscaling.cpu_scale_out_cooldown
    scale_in_cooldown  = var.api_ecs_config.autoscaling.cpu_scale_in_cooldown
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}
resource "aws_appautoscaling_policy" "api_memory" {
  name               = "magische-${var.env}-api-server-memory"
  service_namespace  = aws_appautoscaling_target.api.service_namespace
  resource_id        = aws_appautoscaling_target.api.resource_id
  scalable_dimension = aws_appautoscaling_target.api.scalable_dimension
  policy_type        = "TargetTrackingScaling"
  target_tracking_scaling_policy_configuration {
    target_value       = var.api_ecs_config.autoscaling.memory_target_value
    scale_out_cooldown = var.api_ecs_config.autoscaling.memory_scale_out_cooldown
    scale_in_cooldown  = var.api_ecs_config.autoscaling.memory_scale_in_cooldown
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }
}


resource "aws_ecs_service" "webfront" {
  name            = "magische-${var.env}-webfront"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.webfront.arn
  # launch_type     = "FARGATE"
  desired_count = var.webfront_ecs_config.desired_count
  network_configuration {
    subnets = var.webfront_ecs_config.subnet_ids
    security_groups = [
      aws_security_group.webfront_server.id
    ]
    assign_public_ip = var.webfront_ecs_config.assign_public_ip
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    base              = var.webfront_ecs_config.capacity_provider.fargate_base
    weight            = var.webfront_ecs_config.capacity_provider.fargate_weight
  }
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    base              = var.webfront_ecs_config.capacity_provider.fargate_spot_base
    weight            = var.webfront_ecs_config.capacity_provider.fargate_spot_weight
  }
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.webfront.arn
    container_name   = "magische-${var.env}-webfront"
    container_port   = var.webfront_ecs_config.container_port
  }

  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition,
    ]
  }
  tags = {
    Name    = "magische-${var.env}-webfront-ecs-service"
    Service = "webfront"
    Env     = "${var.env}"
  }
}

# 実質ダミー
resource "aws_ecs_task_definition" "webfront" {
  family                   = "magische-${var.env}-webfront"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.webfront_server_task_exec.arn
  task_role_arn            = aws_iam_role.webfront_server_task.arn
  track_latest             = false
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = var.webfront_ecs_config.cpu_architecture
  }
  container_definitions = jsonencode([
    {
      name  = "magische-${var.env}-webfront"
      image = "nginx"
      portMappings = [
        {
          containerPort = var.webfront_ecs_config.container_port
          hostPort      = var.webfront_ecs_config.host_port
          protocol      = "tcp"
        },
      ]
      # logConfiguration = {
      #   logDriver = "awslogs"
      #   options = {
      #     "awslogs-group"         = "magische-${var.env}-webfront"
      #     "awslogs-region"        = "ap-northeast-1"
      #     "awslogs-stream-prefix" = "magische-${var.env}-webfront"
      #   }
      # }
    },
  ])
  tags = {
    Name    = "magische-${var.env}-webfront-server"
    Service = "webfront"
    Env     = "${var.env}"
  }
}

# autoscaling
# https://qiita.com/neruneruo/items/ccdc22aab86d52580173
resource "aws_appautoscaling_target" "webfront" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.webfront.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  max_capacity       = var.webfront_ecs_config.autoscaling.max_capacity
  min_capacity       = var.webfront_ecs_config.autoscaling.min_capacity
}
resource "aws_appautoscaling_policy" "webfront_cpu" {
  name               = "magische-${var.env}-webfront-server-cpu"
  service_namespace  = aws_appautoscaling_target.webfront.service_namespace
  resource_id        = aws_appautoscaling_target.webfront.resource_id
  scalable_dimension = aws_appautoscaling_target.webfront.scalable_dimension
  policy_type        = "TargetTrackingScaling"
  target_tracking_scaling_policy_configuration {
    target_value       = var.webfront_ecs_config.autoscaling.cpu_target_value
    scale_out_cooldown = var.webfront_ecs_config.autoscaling.cpu_scale_out_cooldown
    scale_in_cooldown  = var.webfront_ecs_config.autoscaling.cpu_scale_in_cooldown
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}
resource "aws_appautoscaling_policy" "webfront_memory" {
  name               = "magische-${var.env}-webfront-server-memory"
  service_namespace  = aws_appautoscaling_target.webfront.service_namespace
  resource_id        = aws_appautoscaling_target.webfront.resource_id
  scalable_dimension = aws_appautoscaling_target.webfront.scalable_dimension
  policy_type        = "TargetTrackingScaling"
  target_tracking_scaling_policy_configuration {
    target_value       = var.webfront_ecs_config.autoscaling.memory_target_value
    scale_out_cooldown = var.webfront_ecs_config.autoscaling.memory_scale_out_cooldown
    scale_in_cooldown  = var.webfront_ecs_config.autoscaling.memory_scale_in_cooldown
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }
}
