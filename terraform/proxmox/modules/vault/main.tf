# DOCKER MANAGER NODES
resource "proxmox_vm_qemu" "vault-vm" {

  # VM General Settings
  target_node = var.proxmox_node
  vmid        = 401
  name        = "prd-vault-1"
  desc        = "HashiCorp Vault Server"
  #clone       = "ubuntu-server-template"
  full_clone = false
  onboot     = true
  os_type    = "cloud-init"
  cores      = 1
  sockets    = 2
  cpu        = "host"
  memory     = 2048
  skip_ipv6  = true
  agent      = 1 # Enable the QEMU Guest Agent

  disks {
    ide {
      ide0 {
        cloudinit {
          storage = "local-zfs"
        }
      }
    }
    virtio {
      virtio0 {
        disk {
          cache     = "none"
          discard   = false
          iothread  = false
          readonly  = false
          replicate = false
          format    = "raw"
          size      = "20G"
          storage   = "local-zfs"
        }
      }
    }
  }

  network {
    bridge = "vmbr0"
    model  = "e1000"
  }

  ipconfig0 = "ip=dhcp"

  lifecycle {
    ignore_changes = [
      vmid
      , vm_state
    ]
  }
}