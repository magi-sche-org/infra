# https://zenn.dev/chario/books/tfc-aws-introductory-book/viewer/05_02_aws_iam_role_create

locals {
  tfc_hostname = "app.terraform.io"

  tfc_organization_name = "magische"
  tfc_project_name      = "magische"
}

data "tls_certificate" "tfc_certificate" {
  url = "https://${local.tfc_hostname}"
}

resource "aws_iam_openid_connect_provider" "tfc_oidc_provider" {
  url = data.tls_certificate.tfc_certificate.url
  client_id_list = [
    "aws.workload.identity",
  ]
  thumbprint_list = [
    data.tls_certificate.tfc_certificate.certificates[0].sha1_fingerprint
  ]
  tags = {
    "Name" = "magische-terraform-cloud-oidc-provider"
  }
}

resource "aws_iam_role" "tfc_oidc_role" {
  name = "terraform_cloud_oidc_role"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess",
  ]
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Effect = "Allow"
          Principal = {
            Federated = "${aws_iam_openid_connect_provider.tfc_oidc_provider.arn}"
          }
          Action = "sts:AssumeRoleWithWebIdentity"
          Condition = {
            StringEquals = {
              "${local.tfc_hostname}:aud" = "aws.workload.identity"
            }
            "ForAnyValue:StringLike" = {
              "${local.tfc_hostname}:sub" = [
                "organization:${local.tfc_organization_name}:project:${local.tfc_project_name}:workspace:magische_infra_base:run_phase:*",
                "organization:${local.tfc_organization_name}:project:${local.tfc_project_name}:workspace:magische_infra_dev_frontend:run_phase:*",
                "organization:${local.tfc_organization_name}:project:${local.tfc_project_name}:workspace:magische_infra_prd_frontend:run_phase:*",
                "organization:${local.tfc_organization_name}:project:${local.tfc_project_name}:workspace:magische_infra_dev_backend:run_phase:*",
                "organization:${local.tfc_organization_name}:project:${local.tfc_project_name}:workspace:magische_infra_prd_backend:run_phase:*",
              ]
            }
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  tags = {
    "Name" = "magische-terraform-cloud-oidc-role"
  }
}
