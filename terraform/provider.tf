terraform {
  cloud {
    organization = "nyah-core"

    workspaces {
      name = "build-it-all"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region  = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}