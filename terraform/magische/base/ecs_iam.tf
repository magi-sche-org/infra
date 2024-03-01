data "aws_iam_policy_document" "ecs_tasks_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "api_server_task" {
  name               = "magische-${var.env}-api-server-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = {
    Name    = "magische-${var.env}-api-server-task"
    Service = "api"
    Env     = "${var.env}"
  }
}

resource "aws_iam_policy" "api_server_task" {
  name        = "magische-${var.env}-api-server-task"
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
    Name    = "magische-${var.env}-api-server-task"
    Service = "api"
    Env     = "${var.env}"
  }
}
resource "aws_iam_role_policy_attachment" "api_server_task" {
  role       = aws_iam_role.api_server_task.name
  policy_arn = aws_iam_policy.api_server_task.arn
}

resource "aws_iam_role" "api_server_task_exec" {
  name               = "magische-${var.env}-api-server-task-exec"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = {
    Name    = "magische-${var.env}-api-server-task-exec"
    Service = "api"
    Env     = "${var.env}"
  }
}

resource "aws_iam_policy" "api_server_task_exec" {
  name        = "magische-${var.env}-api-server-task-exec"
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
      # logを出力するために必要
      {
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "*"
      },
    ],
  })

  tags = {
    Name    = "magische-${var.env}-api-server-task-exec"
    Service = "api"
    Env     = "${var.env}"
  }
}

resource "aws_iam_role_policy_attachment" "api_task_exec" {
  role       = aws_iam_role.api_server_task_exec.name
  policy_arn = aws_iam_policy.api_server_task_exec.arn
}

resource "aws_iam_role_policy_attachment" "api_task_exec_ecs_exec" {
  role       = aws_iam_role.api_server_task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}







resource "aws_iam_role" "webfront_server_task" {
  name               = "magische-${var.env}-webfront-server-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = {
    Name    = "magische-${var.env}-webfront-server-task"
    Service = "webfront"
    Env     = "${var.env}"
  }
}

resource "aws_iam_policy" "webfront_server_task" {
  name        = "magische-${var.env}-webfront-server-task"
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
    Name    = "magische-${var.env}-webfront-server-task"
    Service = "webfront"
    Env     = "${var.env}"
  }
}
resource "aws_iam_role_policy_attachment" "webfront_server_task" {
  role       = aws_iam_role.webfront_server_task.name
  policy_arn = aws_iam_policy.webfront_server_task.arn
}

resource "aws_iam_role" "webfront_server_task_exec" {
  name               = "magische-${var.env}-webfront-server-task-exec"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = {
    Name    = "magische-${var.env}-webfront-server-task-exec"
    Service = "webfront"
    Env     = "${var.env}"
  }
}

resource "aws_iam_policy" "webfront_server_task_exec" {
  name        = "magische-${var.env}-webfront-server-task-exec"
  description = "Allow ECS tasks to interact with other AWS services"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # とりあえず
      # {
      #   Action   = ["s3:GetObject", "s3:PutObject"]
      #   Effect   = "Allow"
      #   Resource = "*"
      # },
      # # logを出力するために必要
      # {
      #   Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
      #   Effect   = "Allow"
      #   Resource = "*"
      # },
      # secret managerからの値取得
      {
        Action = ["secretsmanager:GetSecretValue"]
        Effect = "Allow"
        Resource = [
          aws_secretsmanager_secret.api_server.arn,
          var.rds_config.type == "aurora_mysql_serverless_v2" ? aws_rds_cluster.serverless_v2[0].master_user_secret[0].secret_arn : aws_db_instance.mysql_standalone[0].master_user_secret[0].secret_arn,
        ]
      },
      # kms decrypt
      {
        Action   = ["kms:Decrypt"]
        Effect   = "Allow"
        Resource = aws_kms_key.main.arn
      },
    ],
  })

  tags = {
    Name    = "magische-${var.env}-webfront-server-task-exec"
    Service = "webfront"
    Env     = "${var.env}"
  }
}

resource "aws_iam_role_policy_attachment" "webfront_task_exec" {
  role       = aws_iam_role.webfront_server_task_exec.name
  policy_arn = aws_iam_policy.webfront_server_task_exec.arn
}

resource "aws_iam_role_policy_attachment" "webfront_task_exec_ecs_exec" {
  role       = aws_iam_role.webfront_server_task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
