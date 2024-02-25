resource "aws_ecr_repository" "api" {
  name                 = "magische-${var.env}-api"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "webfront" {
  name                 = "magische-${var.env}-webfront"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "api" {
  repository = aws_ecr_repository.api.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Expire images older than 10"
        selection = {
          tagStatus   = "any",
          countType   = "imageCountMoreThan",
          countNumber = 10,
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_lifecycle_policy" "webfront" {
  repository = aws_ecr_repository.webfront.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Expire images older than 10"
        selection = {
          tagStatus   = "any",
          countType   = "imageCountMoreThan",
          countNumber = 10,
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
