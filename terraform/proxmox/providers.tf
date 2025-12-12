terraform {
  required_version = ">= 1.10.0"

  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc06"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "5.6.0"
    }
  }
}

provider "vault" {
  address = var.vault_address
  token   = var.vault_token
}

provider "proxmox" {
  pm_api_url          = data.vault_kv_secret_v2.proxmox.data["api_url"]
  pm_api_token_id     = data.vault_kv_secret_v2.proxmox.data["api_token_id"]
  pm_api_token_secret = data.vault_kv_secret_v2.proxmox.data["api_token_secret"]

  pm_tls_insecure = true
  pm_timeout      = 900
}