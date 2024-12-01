# Packer Template to create an Windows Server 2022 on Proxmox

packer {
  required_plugins {
    proxmox = {
      version = "=1.2.1"
      source  = "github.com/hashicorp/proxmox"
    }

    windows-update = {
      version = "0.16.8"
      source  = "github.com/rgl/windows-update" # https://github.com/rgl/packer-plugin-windows-update?tab=readme-ov-file
    }
  }
}

# Variable Definitions
variable "proxmox_api_url" {
  type = string
}

variable "proxmox_api_token_id" {
  type = string
}

variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

variable "proxmox_node" {
  type = string
}

variable "win2022_iso_file" {
  type = string
}

variable "cdrom_drive" {
  type        = string
  description = "CD-ROM Driveletter for extra iso"
  default     = "D:"
}

variable "winrm_user" {
  type        = string
  description = "WinRM user"
}

variable "image_index" {
  type = map(string)
}

variable "template" {
  type = string 
  default = "desktop" 
  description = "Template type, can be desktop or core"
  validation {
    condition = (var.template == "desktop") || (var.template == "core")
    error_message = "Should be desktop or core."
  }
}

# VM Template Resource Definiation
source "proxmox-iso" "win2022-server-template" {

  # Proxmox Connection Settings
  proxmox_url = "${var.proxmox_api_url}"
  username    = "${var.proxmox_api_token_id}"
  token       = "${var.proxmox_api_token_secret}"
  # Skip TLS Verification
  insecure_skip_tls_verify = true

  # VM General Settings
  node    = "${var.proxmox_node}"
  vm_id   = "8001"
  vm_name = "win2022-server-template"
  #template_name = "templ-win2022-${var.template}"template_description = "Created on: ${timestamp()}"
  template_description    = "Windows Server 2022 Image"
  qemu_agent              = true
  cpu_type                = "host"
  cores                   = "2"
  memory                  = "4096"
  scsi_controller         = "virtio-scsi-pci"
  machine                 = "q35"  # Less resource overhead and newer chipset
  bios                    = "ovmf" # UEFI
  os                      = "win11"
  cloud_init              = false
  cloud_init_storage_pool = "local-zfs"

  boot_command = ["<enter>"]
  boot_wait    = "7s"

  communicator   = "winrm"
  winrm_username = "${var.winrm_user}"
  winrm_password = "packer"
  winrm_use_ssl  = false
  winrm_insecure = true
  winrm_timeout  = "2h"
  #winrm_port     = "5986"

  efi_config {
    efi_storage_pool  = "local-zfs"
    efi_type          = "4m"
    pre_enrolled_keys = true
  }

  disks {
    disk_size    = "60G"
    format       = "raw"
    storage_pool = "local-zfs"
    type         = "virtio"
  }

  network_adapters {
    model    = "e1000"
    bridge   = "vmbr0"
    firewall = "false"
  }

  boot_iso {
    type     = "scsi"
    iso_file = "${var.win2022_iso_file}"
    unmount  = true
  }

  additional_iso_files {
    cd_files = ["files/drivers/*", "files/scripts/ConfigureRemotingForAnsible.ps1", "files/software/virtio-win-guest-tools.exe"]
    cd_content = {
      "autounattend.xml" = templatefile("files/templates/unattend.pkrtpl", { password = "packer", cdrom_drive = var.cdrom_drive, index = lookup(var.image_index, var.template, "desktop") })
    }
    cd_label         = "Unattend"
    unmount          = true
    iso_storage_pool = "local"
    device           = "sata0"
  }

}

# VM Template Build Definition
build {

  name    = "win2022-server-template"
  sources = ["source.proxmox-iso.win2022-server-template"]

  provisioner "windows-restart" {
  }

  provisioner "windows-update" {
    search_criteria = "IsInstalled=0"
    filters = [
      "exclude:$_.Title -like '*Preview*'",
      "include:$true",
    ]
    update_limit = 25
  }

  provisioner "powershell" {
    script       = "files/scripts/InstallCloudBase.ps1"
    pause_before = "1m"
  }

  provisioner "file" {
    source      = "files/config/"
    destination = "C://Program Files//Cloudbase Solutions//Cloudbase-Init//conf"
  }

  provisioner "powershell" {
    inline = [
      "Set-Service cloudbase-init -StartupType Manual",
      "Stop-Service cloudbase-init -Force -Confirm:$false"
    ]
  }

  provisioner "powershell" {
    inline = [
      "Set-Location -Path \"C:\\Program Files\\Cloudbase Solutions\\Cloudbase-Init\\conf\"",
      "C:\\Windows\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /unattend:unattend.xml"
    ]
  }
}