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

variable "pki_allowed_domains" {
  description = "List of allowed domains for certificates"
  type        = list(string)
}

variable "cert_country" {
  description = "The country of generated certificates"
  type        = list(string)
}

variable "cert_province" {
  description = "The province/state of generated certificates"
  type        = list(string)
}

variable "cert_locality" {
  description = "The locality/city of generated certificates"
  type        = list(string)
}

variable "cert_street_address" {
  description = "The street address of generated certificates"
  type        = list(string)
}

variable "cert_postal_code" {
  description = "The postal code of generated certificates"
  type        = list(string)
}