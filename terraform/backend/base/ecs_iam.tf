data "aws_iam_policy_document" "ecs_tasks_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "server_task" {
  name               = "magische-${var.environment}-${var.service}-server-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = {
    Name    = "magische-${var.environment}-${var.service}-server-task"
    Service = "${var.service}"
    Env     = "${var.environment}"
  }
}

resource "aws_iam_policy" "server_task" {
  name        = "magische-${var.environment}-${var.service}-server-task"
  description = "Allow ECS tasks to interact with other AWS services"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # とりあえず
      {
        Action   = ["s3:GetObject", "s3:PutObject"]
        Effect   = "Allow"
        Resource = "*"
      },
    ],
  })

  tags = {
    Name    = "magische-${var.environment}-${var.service}-server-task"
    Service = "${var.service}"
    Env     = "${var.environment}"
  }
}
resource "aws_iam_role_policy_attachment" "server_task" {
  role       = aws_iam_role.server_task.name
  policy_arn = aws_iam_policy.server_task.arn
}

resource "aws_iam_role" "server_task_exec" {
  name               = "magische-${var.environment}-${var.service}-server-task-exec"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = {
    Name    = "magische-${var.environment}-${var.service}-server-task-exec"
    Service = "${var.service}"
    Env     = "${var.environment}"
  }
}

resource "aws_iam_policy" "server_task_exec" {
  name        = "magische-${var.environment}-${var.service}-server-task-exec"
  description = "Allow ECS tasks to interact with other AWS services"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # とりあえず
      {
        Action   = ["s3:GetObject", "s3:PutObject"]
        Effect   = "Allow"
        Resource = "*"
      },
    ],
  })

  tags = {
    Name    = "magische-${var.environment}-${var.service}-server-task-exec"
    Service = "${var.service}"
    Env     = "${var.environment}"
  }
}

resource "aws_iam_role_policy_attachment" "server_task_exec" {
  role       = aws_iam_role.server_task_exec.name
  policy_arn = aws_iam_policy.server_task_exec.arn
}

resource "aws_iam_role_policy_attachment" "server_task_exec_ecs_exec" {
  role       = aws_iam_role.server_task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
