terraform {
  cloud {
    organization = "magische"

    workspaces {
      project = "magische"
      name    = "magische_infra_base"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.38.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
  # profile = "magische"
}
# provider "aws" {
#   alias   = "virginia"
#   profile = "magische"
#   region  = "us-east-1"
# }
