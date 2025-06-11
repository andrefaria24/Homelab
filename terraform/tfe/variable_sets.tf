resource "tfe_variable_set" "proxmox" {
  name         = "Proxmox"
  description  = "Proxmox Variable Set"
  organization = tfe_organization.default.name
}

resource "tfe_variable_set" "vault" {
  name         = "Vault"
  description  = "Vault Variable Set"
  organization = tfe_organization.default.name
}

resource "tfe_project_variable_set" "proxmox" {
  project_id      = tfe_project.onprem.id
  variable_set_id = tfe_variable_set.proxmox.id
}

resource "tfe_project_variable_set" "vault" {
  project_id      = tfe_project.onprem.id
  variable_set_id = tfe_variable_set.vault.id
}

resource "tfe_variable" "proxmox_node" {
  key             = "proxmox_node"
  value           = var.proxmox_info.proxmox_node
  category        = "terraform"
  description     = "Proxmox Node"
  variable_set_id = tfe_variable_set.proxmox.id
}

resource "tfe_variable" "vault_address" {
  key             = "vault_address"
  value           = var.vault_info.vault_address
  category        = "terraform"
  description     = "Vault Address"
  variable_set_id = tfe_variable_set.vault.id
}

resource "tfe_variable" "vault_token" {
  key             = "vault_token"
  value           = var.vault_info.vault_token
  category        = "terraform"
  description     = "Vault Token"
  sensitive       = true
  variable_set_id = tfe_variable_set.vault.id
}