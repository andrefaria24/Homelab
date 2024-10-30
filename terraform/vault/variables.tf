variable "vault_address" {
  description = "Vault server URL"
  type        = string
}

variable "vault_token" {
  description = "Vault token for Terraform auth"
  type        = string
  sensitive   = true
}

variable "admin_username" {
  description = "Administrator username for Userpass auth"
  type        = string
}

variable "admin_password" {
  description = "Administrator password for Userpass auth"
  type        = string
  sensitive = true
}