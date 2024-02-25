resource "aws_ecs_cluster" "main" {
  name = "magische-${var.environment}-${var.service}"

  tags = {
    Name    = "magische-${var.environment}-${var.service}-ecs-cluster"
    Service = "${var.service}"
    Env     = "${var.environment}"
  }
}

resource "aws_ecs_service" "server" {
  name            = "magische-${var.environment}-${var.service}-server"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.server.arn
  # launch_type     = "FARGATE"
  desired_count = 1
  network_configuration {
    subnets = var.public_subnet_ids[*]
    security_groups = [
      aws_security_group.server.id,
    ]
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    base              = var.server_ecs_config.capacity_provider.fargate_base
    weight            = var.server_ecs_config.capacity_provider.fargate_weight
  }
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    base              = var.server_ecs_config.capacity_provider.fargate_spot_base
    weight            = var.server_ecs_config.capacity_provider.fargate_spot_weight
  }
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.server.arn
    container_name   = "magische-${var.environment}-${var.service}-server"
    container_port   = var.server_ecs_config.container_port
  }

  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition,
    ]
  }
  tags = {
    Name    = "magische-${var.environment}-${var.service}-ecs-service"
    Service = "${var.service}"
    Env     = "${var.environment}"
  }
}

resource "aws_ecs_task_definition" "server" {
  family = "magische-${var.environment}-${var.service}-server"
  # network_mode             = "awsvpc"
  network_mode             = "ip"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.server_task_exec.arn
  task_role_arn            = aws_iam_role.server_task.arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
  container_definitions = jsonencode([
    {
      name  = "magische-${var.environment}-${var.service}-server"
      image = "nginx"
      portMappings = [
        {
          containerPort = var.server_ecs_config.container_port
          hostPort      = var.server_ecs_config.container_port
        },
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "magische-${var.environment}-${var.service}-server"
          "awslogs-region"        = "ap-northeast-1"
          "awslogs-stream-prefix" = "magische-${var.environment}-${var.service}-server"
        }
      }
    },
  ])
  tags = {
    Name    = "magische-${var.environment}-${var.service}-server"
    Service = "${var.service}"
    Env     = "${var.environment}"
  }
}

# autoscaling
# https://qiita.com/neruneruo/items/ccdc22aab86d52580173
resource "aws_appautoscaling_target" "server" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.server.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  max_capacity       = var.server_ecs_config.autoscaling.max_capacity
  min_capacity       = var.server_ecs_config.autoscaling.min_capacity
}
resource "aws_appautoscaling_policy" "server_cpu" {
  name               = "magische-${var.environment}-${var.service}-server"
  service_namespace  = aws_appautoscaling_target.server.service_namespace
  resource_id        = aws_appautoscaling_target.server.resource_id
  scalable_dimension = aws_appautoscaling_target.server.scalable_dimension
  policy_type        = "TargetTrackingScaling"
  target_tracking_scaling_policy_configuration {
    target_value       = var.server_ecs_config.autoscaling.cpu_target_value
    scale_out_cooldown = var.server_ecs_config.autoscaling.cpu_scale_out_cooldown
    scale_in_cooldown  = var.server_ecs_config.autoscaling.cpu_scale_in_cooldown
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}
resource "aws_appautoscaling_policy" "server_memory" {
  name               = "magische-${var.environment}-${var.service}-server"
  service_namespace  = aws_appautoscaling_target.server.service_namespace
  resource_id        = aws_appautoscaling_target.server.resource_id
  scalable_dimension = aws_appautoscaling_target.server.scalable_dimension
  policy_type        = "TargetTrackingScaling"
  target_tracking_scaling_policy_configuration {
    target_value       = var.server_ecs_config.autoscaling.memory_target_value
    scale_out_cooldown = var.server_ecs_config.autoscaling.memory_scale_out_cooldown
    scale_in_cooldown  = var.server_ecs_config.autoscaling.memory_scale_in_cooldown
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }
}

