terraform {
  cloud {
    organization = "magische"

    workspaces {
      project = "magische"
      name    = "magische_infra_dev_backend"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.38.0"
    }
    # tfe = {
    #   source  = "hashicorp/tfe"
    #   version = "~> 0.52.0"
    # }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

# data.terraform_remote_state.base.outputs.で参照
data "terraform_remote_state" "base" {
  backend = "remote"
  config = {
    organization = "magische"
    workspaces = {
      # project = "magische" # errorになる
      name = "magische_infra_base"
    }
  }
}

# data.tfe_outputs.base.values.で参照
# data "tfe_outputs" "base" {
#   organization = "magische"
#   workspace    = "magische_infra_base"
#   # config = {
#   #   organization = "magische"
#   #   workspaces = {
#   #     project = "magische"
#   #     name    = "magische_infra_base"
#   #   }
#   # }
# }
