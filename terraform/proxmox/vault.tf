# DOCKER MANAGER NODES
resource "proxmox_vm_qemu" "vault-vm" {

  # VM General Settings
  target_node = var.proxmox_node
  vmid        = 101
  name        = "faria-vault"
  desc        = "HashiCorp Vault Server"
  #clone       = "ubuntu-server-template"
  full_clone  = false
  onboot      = true
  os_type     = "cloud-init"
  cores       = 2
  sockets     = 1
  cpu         = "host"
  memory      = 2048
  skip_ipv6   = true
  # Enable the QEMU Guest Agent
  agent = 1

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
            cache = "none"
            discard = false
            iothread = false
            readonly = false
            replicate = false
            format = "raw"
            size = "20G"
            storage = "local-zfs"
        }
      }
    }
  }

  network {
    bridge = "vmbr0"
    model  = "e1000"
  }

  # ipconfig0 = "ip=0.0.0.0/0,gw=0.0.0.0"
  ipconfig0 = "ip=dhcp"

  lifecycle {
    ignore_changes = [
       vmid
      ,vm_state
    ]
  }
}