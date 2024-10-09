resource "proxmox_vm_qemu" "k3s-cluster" {
    count = 3

  # VM General Settings
  target_node = var.proxmox_node
  vmid        = 301 + count.index
  name        = "k3s-${count.index + 1}"
  desc        = "k3s Node"
  clone       = "ubuntu-server-template"
  full_clone  = true
  onboot      = true
  os_type     = "cloud-init"
  cores       = 1
  sockets     = 2
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
            size = "40G"
            storage = "local-zfs"
        }
      }
    }
  }

  network {
    bridge = "vmbr0"
    model  = "virtio"
  }

  # Manually Set IP Address and Gateway
  # ipconfig0 = "ip=0.0.0.0/0,gw=0.0.0.0"
  ipconfig0 = "ip=dhcp"
}