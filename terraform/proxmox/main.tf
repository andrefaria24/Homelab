module "docker-hosts" {
  source = "./modules/docker-hosts"

  proxmox_node = var.proxmox_node
}

module "vault" {
  source = "./modules/vault"

  proxmox_node = var.proxmox_node
}