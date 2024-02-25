locals {
  github_owner_name = "magische"
}

output "gha_oidc_deploy_api_role_arn" {
  value = aws_iam_role.gha_oidc_deploy_api.arn
}
output "gha_oidc_deploy_webfront_role_arn" {
  value = aws_iam_role.gha_oidc_deploy_webfront.arn
}

resource "aws_iam_role" "gha_oidc_deploy_api" {
  name = "magische-${var.env}-api-deploy"
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Effect = "Allow"
          Principal = {
            Federated = var.gha_oidc.provider_arn
          }
          Action = "sts:AssumeRoleWithWebIdentity"
          Condition = {
            StringEquals = {
              "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            }
            "ForAnyValue:StringEquals" = {
              "token.actions.githubusercontent.com:sub" = [
                "repo:${local.github_owner_name}/backend:ref:refs/heads/${var.gha_oidc.branch_name}",
                "repo:${local.github_owner_name}/backend:pull_request",
                # "repo:${local.github_owner_name}/backend:environment:${var.env}",
              ]
            }
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
}


# attach policy to role
resource "aws_iam_role_policy_attachment" "deploy_api_ecspresso_exec" {
  role       = aws_iam_role.gha_oidc_deploy_api.name
  policy_arn = var.ecspresso_exec_policy_arn
}

# ecr push
resource "aws_iam_role_policy_attachment" "deploy_api_ecr_dkr" {
  role       = aws_iam_role.gha_oidc_deploy_api.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role" "gha_oidc_deploy_webfront" {
  name = "magische-${var.env}-webfront-deploy"
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Effect = "Allow"
          Principal = {
            Federated = var.gha_oidc.provider_arn
          }
          Action = "sts:AssumeRoleWithWebIdentity"
          Condition = {
            StringEquals = {
              "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            }
            "ForAnyValue:StringEquals" = {
              "token.actions.githubusercontent.com:sub" = [
                "repo:${local.github_owner_name}/frontend:ref:refs/heads/${var.gha_oidc.branch_name}",
                "repo:${local.github_owner_name}/frontend:pull_request",
                # "repo:${local.github_owner_name}/frontend:environment:${var.env}",
              ]
            }
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_role_policy_attachment" "deploy_webfront_ecspresso_exec" {
  role       = aws_iam_role.gha_oidc_deploy_webfront.name
  policy_arn = var.ecspresso_exec_policy_arn
}
resource "aws_iam_role_policy_attachment" "deploy_webfront_ecr_dkr" {
  role       = aws_iam_role.gha_oidc_deploy_webfront.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}



# # GitHub Actions側からはこのIAM Roleを指定する
# resource "aws_iam_role" "gha_oidc" {
#   name               = "github-actions"
#   assume_role_policy = data.aws_iam_policy_document.github_actions.json
#   description        = "IAM Role for GitHub Actions OIDC"
# }

# locals {
#   allowed_github_repositories = [
#     "foo",
#     "bar",
#   ]
#   github_org_name = "my-organization"
#   full_paths = [
#     for repo in local.allowed_github_repositories : "repo:${local.github_org_name}/${repo}:*"
#   ]
# }

# # see: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services#configuring-the-role-and-trust-policy
# data "aws_iam_policy_document" "github_actions" {
#   statement {
#     actions = [
#       "sts:AssumeRoleWithWebIdentity",
#     ]

#     principals {
#       type = "Federated"
#       identifiers = [
#         aws_iam_openid_connect_provider.github_actions.arn
#       ]
#     }

#     # OIDCを利用できる対象のGitHub Repositoryを制限する
#     condition {
#       test     = "StringLike"
#       variable = "token.actions.githubusercontent.com:sub"
#       values   = local.full_paths
#     }
#   }
# }

# # 実際に利用する際にはこれに加えてdeny定義を追加付与するなどして、CI/CD用にカスタマイズすることを強く推奨
# resource "aws_iam_role_policy_attachment" "admin" {
#   policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
#   role       = aws_iam_role.github_actions.name
# }
