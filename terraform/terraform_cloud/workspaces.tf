module "module_magische_dev_frontend" {
  source                     = "./modules"
  organization_name          = tfe_organization.magische_organization.name
  project_id                 = tfe_project.magische_project.id
  GITHUB_APP_INSTALLATION_ID = var.GITHUB_APP_INSTALLATION_ID
  workspace_name             = "magische_infra_base"
  working_directory          = "terraform/base"
}

module "module_magische_dev_frontend" {
  source                     = "./modules"
  organization_name          = tfe_organization.magische_organization.name
  project_id                 = tfe_project.magische_project.id
  GITHUB_APP_INSTALLATION_ID = var.GITHUB_APP_INSTALLATION_ID
  workspace_name             = "magische_infra_dev_frontend"
  working_directory          = "terraform/frontend/dev"
}

module "module_magische_dev_backend" {
  source                     = "./modules"
  organization_name          = tfe_organization.magische_organization.name
  project_id                 = tfe_project.magische_project.id
  GITHUB_APP_INSTALLATION_ID = var.GITHUB_APP_INSTALLATION_ID
  workspace_name             = "magische_infra_dev_backend"
  working_directory          = "terraform/backend/dev"
}

module "module_magische_prd_frontend" {
  source                     = "./modules"
  organization_name          = tfe_organization.magische_organization.name
  project_id                 = tfe_project.magische_project.id
  GITHUB_APP_INSTALLATION_ID = var.GITHUB_APP_INSTALLATION_ID
  workspace_name             = "magische_infra_prd_frontend"
  working_directory          = "terraform/frontend/prd"
}

module "module_magische_prd_backend" {
  source                     = "./modules"
  organization_name          = tfe_organization.magische_organization.name
  project_id                 = tfe_project.magische_project.id
  GITHUB_APP_INSTALLATION_ID = var.GITHUB_APP_INSTALLATION_ID
  workspace_name             = "magische_infra_prd_backend"
  working_directory          = "terraform/backend/prd"
}

