data "vault_kv_secret_v2" "proxmox" {
  mount = "kvv2"
  name  = "proxmox"
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

# Docker hosts
resource "proxmox_vm_qemu" "docker-hosts" {
  count = 1

  target_node = local.target_node
  # vmid        = 301 + count.index
  name        = "faria-docker-${count.index + 1}"
  desc        = "Docker production environment"
  # clone       = local.clone
  full_clone  = local.full_clone
  define_connection_info = false
  onboot      = local.onboot
  os_type     = local.os_type
  cores       = local.cores
  sockets     = local.sockets
  cpu         = local.cpu
  memory      = local.memory
  skip_ipv6   = local.skip_ipv6
  agent       = local.agent

  disks {
    ide {
      ide0 {
        cloudinit {
          storage = local.storage
        }
      }
    }
    virtio {
      virtio0 {
        disk {
          cache     = local.cache
          discard   = local.discard
          iothread  = local.iothread
          readonly  = local.readonly
          replicate = local.replicate
          format    = local.format
          size      = local.size
          storage   = local.storage
        }
      }
    }
  }

  network {
    bridge = local.bridge
    model  = local.model
  }

  ipconfig0 = local.ipconfig

  lifecycle {
    ignore_changes = [vm_state]
  }
}