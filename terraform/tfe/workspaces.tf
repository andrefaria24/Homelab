locals {
  terraform_version = "~>1.10.0"
}

resource "tfe_workspace" "proxmox" {
  name              = "Proxmox"
  organization      = tfe_organization.default.name
  project_id        = tfe_project.onprem.id
  terraform_version = local.terraform_version
}