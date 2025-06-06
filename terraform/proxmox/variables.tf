variable "proxmox_node" {
  description = "Proxmox Node Name"
  type        = string
}

variable "vault_token" {
  description = "Vault token for Terraform auth"
  type        = string
  sensitive   = true
}