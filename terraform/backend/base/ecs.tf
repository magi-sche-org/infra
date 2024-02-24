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
  launch_type     = "FARGATE"
  desired_count   = 1
  network_configuration {
    subnets = var.private_subnet_ids[*]
    security_groups = [
      aws_security_group.main.id,
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
  # load_balancer {
  #   target_group_arn = aws_lb_target_group.main.arn
  #   container_name   = "main"
  #   container_port   = 80
  # }
  # depends_on = [
  #   aws_iam_role_policy_attachment.ecs_execution_role,
  # ]
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
  family                   = "magische-${var.environment}-${var.service}-server"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([
    {
      name  = "magische-${var.environment}-${var.service}-server"
      image = "nginx"
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        },
      ]
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

