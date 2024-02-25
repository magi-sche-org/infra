# resource "tfe_organization" "magische_organization" {
#   name  = "magische"
#   email = "spritz.pickle-08@icloud.com"
# }

# resource "tfe_project" "magische_project" {
#   name         = "magische"
#   organization = tfe_organization.magische_organization.name
# }

variable "GITHUB_APP_INSTALLATION_ID" {
  type = string
}
variable "organization_name" {
  type = string
}
variable "project_id" {
  type = string
}
variable "workspace_name" {
  type = string
}
variable "working_directory" {
  type = string
}
variable "tfe_token_for_remote_state" {
  type        = string
  sensitive   = true
  description = "use for terraform remote state"
}

variable "remote_state_consumer_ids" {
  type = list(string)
}

resource "tfe_workspace" "magische_infra_terraform_cloud" {
  name         = var.workspace_name
  organization = var.organization_name
  project_id   = var.project_id
  auto_apply   = true
  vcs_repo {
    identifier                 = "magi-sche-org/magische-infra"
    branch                     = "main"
    github_app_installation_id = var.GITHUB_APP_INSTALLATION_ID
  }
  working_directory = var.working_directory
  tag_names         = []

  remote_state_consumer_ids = var.remote_state_consumer_ids
  # remote_state_consumer_ids = [
  #   module.module_magische_dev_backend.workspace_id,
  #   module.module_magische_dev_frontend.workspace_id,
  #   module.module_magische_prd_backend.workspace_id,
  #   module.module_magische_prd_frontend.workspace_id,
  # ]
  # global_remote_state = true
}

# resource "tfe_workspace_settings" "magische_infra_terraform_cloud" {
#   workspace_id = tfe_workspace.magische_infra_terraform_cloud.id
# }

resource "tfe_variable" "tfc_aws_provider_auth" {
  key          = "TFC_AWS_PROVIDER_AUTH"
  value        = true
  category     = "env"
  workspace_id = tfe_workspace.magische_infra_terraform_cloud.id
}

resource "tfe_variable" "tfc_aws_run_role_arn" {
  key          = "TFC_AWS_RUN_ROLE_ARN"
  value        = "arn:aws:iam::905418376731:role/terraform_cloud_oidc_role"
  category     = "env"
  workspace_id = tfe_workspace.magische_infra_terraform_cloud.id
}

resource "tfe_variable" "tfc_aws_run_role_external_id" {
  key          = "TFC_TOKEN"
  value        = var.tfe_token_for_remote_state
  sensitive    = true
  category     = "env"
  workspace_id = tfe_workspace.magische_infra_terraform_cloud.id
}

output "workspace_id" {
  value = tfe_workspace.magische_infra_terraform_cloud.id
}
