variable "terraform_address" {
  description = "Terraform Enterprise address"
  type        = string
}

variable "tfe_token" {
  description = "Terraform Enterprise token"
  type        = string
  sensitive   = true
}

variable "tfe_organization" {
  description = "Terraform Enterprise organization name"
  type        = string
}

variable "tfe_email" {
  description = "Email for Terraform Enterprise organization"
  type        = string
}

variable "proxmox_info" {
  description = "Proxmox related values"
  type        = map(string)
}

variable "vault_info" {
  description = "Vault related values"
  type        = map(string)
}