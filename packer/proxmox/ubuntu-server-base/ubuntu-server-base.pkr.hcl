# Packer Template to create an Ubuntu Server (Noble 24.04.x) on Proxmox

packer {
  required_plugins {
    proxmox = {
      version = "=1.2.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

# Variable Definitions
variable "proxmox_node" {
  type = string
}

variable "ubuntu_iso_file" {
  type = string
}

variable "packer_http_bind_address" {
  type = string
}

variable "ssh_username" {
  type = string
}

variable "ssh_password" {
  type      = string
  sensitive = true
}

# VM Template Resource Definiation
source "proxmox-iso" "ubuntu-server-template" {

  # Proxmox Connection Settings
  proxmox_url              = vault("/kvv2/data/proxmox", "api_url")
  username                 = vault("/kvv2/data/proxmox", "api_token_id")
  token                    = vault("/kvv2/data/proxmox", "api_token_secret")
  insecure_skip_tls_verify = false

  # VM General Settings
  node                 = "${var.proxmox_node}"
  vm_id                = "8000"
  vm_name              = "ubuntu-server-template"
  template_description = "Ubuntu Server 24.04 Image"
  qemu_agent           = true
  cores                = "2"
  memory               = "2048"
  scsi_controller      = "virtio-scsi-pci"

  boot_iso {
    type     = "scsi"
    iso_file = "${var.ubuntu_iso_file}"
    unmount  = true
  }

  disks {
    disk_size    = "20G"
    format       = "raw"
    storage_pool = "local-zfs"
    type         = "virtio"
  }

  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = "false"
  }

  # Cloud-Init Settings
  cloud_init              = true
  cloud_init_storage_pool = "local-zfs"
  
  # Packer Boot Commands
  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    "<bs><bs><bs><bs><wait>",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
    "<f10><wait>"
  ]

  boot         = "c"
  boot_wait    = "10s"
  communicator = "ssh"

  # Packer Autoinstall Settings
  http_directory    = "./http"
  http_bind_address = "${var.packer_http_bind_address}"
  http_port_min     = 8802
  http_port_max     = 8802

  ssh_username = "${var.ssh_username}"

  # (Option 1) User Password
  # ssh_password        = "${var.ssh_password}"
  # (Option 2) Private SSH Key file
  ssh_private_key_file = "~/.ssh/id_rsa"

  # Timeout Settings
  ssh_timeout = "15m"
  ssh_pty     = false
}

# VM Template Build Definition
build {

  name    = "ubuntu-server-template"
  sources = ["source.proxmox-iso.ubuntu-server-template"]

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox
  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "sudo rm /etc/ssh/ssh_host_*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo apt -y autoremove --purge",
      "sudo apt -y clean",
      "sudo apt -y autoclean",
      "sudo cloud-init clean",
      "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "sudo rm -f /etc/netplan/00-installer-config.yaml",
      "sudo sync"
    ]
  }

  provisioner "file" {
    source      = "./files/99-pve.cfg"
    destination = "/tmp/99-pve.cfg"
  }

  provisioner "shell" {
    inline = ["sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg"]
  }
}