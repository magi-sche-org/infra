terraform {
  cloud {
    organization = "magische"

    workspaces {
      project = "magische"
      name    = "magische_infra_terraform_cloud"
    }
  }
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.52.0"
    }
  }
}
