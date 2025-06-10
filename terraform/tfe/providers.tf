terraform {
  required_version = ">= 1.10.0"

  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "0.66.0"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "5.0.0"
    }
  }
}

provider "tfe" {
  hostname        = var.terraform_address
  token           = var.tfe_token
  organization    = var.tfe_organization
  ssl_skip_verify = true
}

provider "vault" {
  address = var.vault_address
  token   = var.vault_token
}