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