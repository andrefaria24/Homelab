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
  sensitive   = true
}

variable "cn_root" {
  description = "CN of root certificate"
  type        = string
}

variable "cn_intermediate" {
  description = "CN of intermediate certificate"
  type        = string
}

variable "issuer_name" {
  description = "Certificate issuer name"
  type        = string
}

variable "allowed_domains" {
  description = "Allowed domains for PKI role"
  type        = list(string)
}

variable "cn_intermediate_role_name" {
  description = "CN intermediate role name"
  type        = string
}