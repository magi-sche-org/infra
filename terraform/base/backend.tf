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
}
provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}
