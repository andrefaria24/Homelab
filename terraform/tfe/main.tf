resource "tfe_organization" "default" {
  name  = var.tfe_organization
  email = var.tfe_email
}

resource "tfe_project" "default" {
  organization = tfe_organization.default.name
  name         = "Default Project"
}

resource "tfe_registry_provider" "vault" {
  organization = tfe_organization.default.name

  registry_name = "public"
  namespace     = "hashicorp"
  name          = "vault"
}

resource "tfe_registry_provider" "proxmox" {
  organization = tfe_organization.default.name

  registry_name = "public"
  namespace     = "telmate"
  name          = "proxmox"
}