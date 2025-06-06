data "vault_kv_secret_v2" "proxmox" {
  mount = "kvv2"
  name  = "proxmox"
}

module "docker-hosts" {
  source = "./modules/docker-hosts"

  proxmox_node = var.proxmox_node
}