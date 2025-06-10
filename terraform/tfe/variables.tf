variable "vault_address" {
  description = "Vault address"
  type        = string
}

variable "vault_token" {
  description = "Vault token for Terraform auth"
  type        = string
  sensitive   = true
}

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