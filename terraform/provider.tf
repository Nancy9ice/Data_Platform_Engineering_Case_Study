terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  cloud {
    organization = "nyah-core"

    workspaces {
      name = "build-it-all"
    }
  }

  required_version = ">= 1.3.0"
}

# provider for aws cloud 

# AWS access and secret keys are configured 
# on terraform cloud as env runtime variables
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}
