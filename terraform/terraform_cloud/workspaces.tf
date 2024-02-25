module "module_magische_base" {
  source                     = "./modules"
  organization_name          = tfe_organization.magische_organization.name
  project_id                 = tfe_project.magische_project.id
  GITHUB_APP_INSTALLATION_ID = var.GITHUB_APP_INSTALLATION_ID
  tfe_token_for_remote_state = var.TFE_TOKEN_FOR_REMOTE_STATE
  workspace_name             = "magische_infra_base"
  working_directory          = "terraform/base"
  remote_state_consumer_ids = [
    module.module_magische_dev_backend.workspace_id,
    module.module_magische_dev_frontend.workspace_id,
    module.module_magische_prd_backend.workspace_id,
    module.module_magische_prd_frontend.workspace_id,
  ]
}

module "module_magische_dev_frontend" {
  source                     = "./modules"
  organization_name          = tfe_organization.magische_organization.name
  project_id                 = tfe_project.magische_project.id
  GITHUB_APP_INSTALLATION_ID = var.GITHUB_APP_INSTALLATION_ID
  tfe_token_for_remote_state = var.TFE_TOKEN_FOR_REMOTE_STATE
  workspace_name             = "magische_infra_dev_frontend"
  working_directory          = "terraform/frontend/dev"
  remote_state_consumer_ids  = []
}

module "module_magische_dev_backend" {
  source                     = "./modules"
  organization_name          = tfe_organization.magische_organization.name
  project_id                 = tfe_project.magische_project.id
  GITHUB_APP_INSTALLATION_ID = var.GITHUB_APP_INSTALLATION_ID
  tfe_token_for_remote_state = var.TFE_TOKEN_FOR_REMOTE_STATE
  workspace_name             = "magische_infra_dev_backend"
  working_directory          = "terraform/backend/dev"
  remote_state_consumer_ids  = []
}

module "module_magische_prd_frontend" {
  source                     = "./modules"
  organization_name          = tfe_organization.magische_organization.name
  project_id                 = tfe_project.magische_project.id
  GITHUB_APP_INSTALLATION_ID = var.GITHUB_APP_INSTALLATION_ID
  tfe_token_for_remote_state = var.TFE_TOKEN_FOR_REMOTE_STATE
  workspace_name             = "magische_infra_prd_frontend"
  working_directory          = "terraform/frontend/prd"
  remote_state_consumer_ids  = []
}

module "module_magische_prd_backend" {
  source                     = "./modules"
  organization_name          = tfe_organization.magische_organization.name
  project_id                 = tfe_project.magische_project.id
  GITHUB_APP_INSTALLATION_ID = var.GITHUB_APP_INSTALLATION_ID
  tfe_token_for_remote_state = var.TFE_TOKEN_FOR_REMOTE_STATE
  workspace_name             = "magische_infra_prd_backend"
  working_directory          = "terraform/backend/prd"
  remote_state_consumer_ids  = []
}

