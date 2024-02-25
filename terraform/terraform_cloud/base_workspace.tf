resource "tfe_organization" "magische_organization" {
  name  = "magische"
  email = "spritz.pickle-08@icloud.com"
}

resource "tfe_project" "magische_project" {
  name         = "magische"
  organization = tfe_organization.magische_organization.name
}

variable "GITHUB_APP_INSTALLATION_ID" {
  type = string
}

variable "TFE_TOKEN_FOR_REMOTE_STATE" {
  type        = string
  sensitive   = true
  description = "use for terraform remote state"
}

resource "tfe_workspace" "magische_infra_terraform_cloud" {
  name         = "magische_infra_terraform_cloud"
  organization = tfe_organization.magische_organization.name
  project_id   = tfe_project.magische_project.id
  auto_apply   = true
  vcs_repo {
    identifier                 = "magi-sche-org/magische-infra"
    branch                     = "main"
    github_app_installation_id = var.GITHUB_APP_INSTALLATION_ID
  }
  working_directory = "terraform/terraform_cloud"
  remote_state_consumer_ids = [
    module.module_magische_base.workspace_id,
  ]
  tag_names = []
}

resource "tfe_workspace_settings" "magische_infra_terraform_cloud" {
  workspace_id = tfe_workspace.magische_infra_terraform_cloud.id
}
