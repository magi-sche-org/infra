# see: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc_verify-thumbprint.html
# see: https://github.com/aws-actions/configure-aws-credentials/issues/357#issuecomment-1011642085
data "http" "github_actions_openid_configuration" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

data "tls_certificate" "github_actions" {
  url = jsondecode(data.http.github_actions_openid_configuration.response_body).jwks_uri
}


resource "aws_iam_openid_connect_provider" "gha" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  # ref: https://qiita.com/minamijoyo/items/eac99e4b1ca0926c4310
  # ref: https://zenn.dev/yukin01/articles/github-actions-oidc-provider-terraform
  thumbprint_list = [data.tls_certificate.github_actions.certificates[0].sha1_fingerprint]

  tags = {
    "Name" = "github-actions-oidc-provider"
  }
}

resource "aws_iam_policy" "ecspresso_exec" {
  name        = "ecspresso-exec"
  description = "Allow ECS tasks to interact with other AWS services"
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Sid : "ecspresso",
          Effect : "Allow",
          Action : [
            "application-autoscaling:Describe*",
            "application-autoscaling:Register*",
            "codedeploy:BatchGet*",
            "codedeploy:CreateDeployment",
            "codedeploy:List*",
            "ecr:ListImages",
            "ecs:*",
            "elasticloadbalancing:DescribeTargetGroups",
            "iam:GetRole",
            "iam:PassRole",
            "logs:GetLogEvents",
            "secretsmanager:GetSecretValue",
            "servicediscovery:GetNamespace",
            "ssm:GetParameter",
            "sts:AssumeRole",
          ],
          "Resource" : "*"
        }
      ]
    }
  )

  tags = {
    Name = "ecspresso-exec"
  }
}

