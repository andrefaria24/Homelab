ephemeral "vault_kv_secret_v2" "proxmox" {
  mount = "kvv2"
  name  = "proxmox/terraform"
}

locals {
  # VM General Settings
  target_node = var.proxmox_node
  clone       = "ubuntu-server-template"
  full_clone  = false
  onboot      = true
  os_type     = "cloud-init"
  cores       = 1
  sockets     = 2
  cpu         = "host"
  memory      = 4096
  skip_ipv6   = true
  agent       = 1 # Enable the QEMU Guest Agent

  # Disk Settings
  storage   = "local-zfs"
  cache     = "none"
  discard   = false
  iothread  = false
  readonly  = false
  replicate = false
  format    = "raw"
  size      = "60G"

  # Network Settings
  bridge   = "vmbr0"
  model    = "e1000"
  ipconfig = "ip=dhcp"
}