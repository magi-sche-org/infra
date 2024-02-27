terraform {
  cloud {
    organization = "magische"

    workspaces {
      project = "magische"
      name    = "magische_infra_dev"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.38.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}
# provider "aws" {
#   alias  = "virginia"
#   region = "us-east-1"
# }

# data.terraform_remote_state.base.outputs.で参照
data "terraform_remote_state" "base" {
  backend = "remote"
  config = {
    organization = "magische"
    workspaces = {
      name = "magische_infra_base"
    }
  }
}
