variable "proxmox_api_url" {
  description = "Proxmox Full API URL"
  type        = string
}

variable "proxmox_api_token_id" {
  description = "Proxmox Terraform Token ID"
  type        = string
}

variable "proxmox_api_token_secret" {
  description = "Proxmox Terraform Token Secret"
  type        = string
  sensitive   = true
}