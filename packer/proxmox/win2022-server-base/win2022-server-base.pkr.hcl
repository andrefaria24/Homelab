# Packer Template to create a Windows Server (2022) image on Proxmox

packer {
  required_plugins {
    windows-update = {
      version = "0.14.3"
      source  = "github.com/rgl/windows-update"
    }
    proxmox = {
      version = "=1.2.2"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

# Variable Definitions
variable "template" {
  type        = string
  default     = "desktop"
  description = "Template type can be desktop or core"
  validation {
    condition     = (var.template == "desktop") || (var.template == "core")
    error_message = "Should be desktop or core."
  }
}

variable "image_index" {
  type = map(string)
}

variable "proxmox_api_url" {
  type        = string
  description = "Proxmox Server URL"
}

variable "proxmox_api_token_id" {
  type        = string
  description = "Proxmox Token ID"
  sensitive   = true
}

variable "proxmox_api_token_secret" {
  type        = string
  description = "Proxmox Token Secret"
  sensitive   = true
}

variable "proxmox_node" {
  type        = string
  description = "Proxmox cluster node"
}

variable "win2022_iso_file" {
  type        = string
  description = "Location of ISO file in the Proxmox environment"
}

variable "winrm_user" {
  type        = string
  description = "WinRM user"
}

variable "winrm_password" {
  type        = string
  description = "WinRM password"
  sensitive   = true
}

variable "winrm_host" {
  type        = string
  description = "WinRM host"
}

variable "cdrom_drive" {
  type        = string
  description = "CD-ROM Driveletter for extra iso"
  default     = "D:"
}

# VM Template Resource Definiation
source "proxmox-iso" "windows2022" {

  # Proxmox Connection Settings
  proxmox_url              = var.proxmox_api_url
  username                 = var.proxmox_api_token_id
  token                    = var.proxmox_api_token_secret
  insecure_skip_tls_verify = true

  # VM General Settings
  vm_id                   = "9000"
  vm_name                 = "windows-server-2022-template"
  template_description    = "Windows Server 2022 Image"
  node                    = var.proxmox_node
  bios                    = "ovmf" # UEFI
  machine                 = "q35"  # Less resource overhead and newer chipset
  memory                  = "4096"
  cores                   = 2
  sockets                 = 1
  cpu_type                = "host"
  os                      = "win11"
  scsi_controller         = "virtio-scsi-pci"
  cloud_init              = false
  cloud_init_storage_pool = "local-zfs"

  efi_config {
    efi_storage_pool  = "local-zfs"
    pre_enrolled_keys = true
    efi_type          = "4m"
  }

  boot_iso {
    type     = "scsi"
    iso_file = var.win2022_iso_file
    unmount  = true
  }

  additional_iso_files {
    #cd_files = ["./build_files/drivers/*", "./build_files/scripts/enableSSH.ps1", "./build_files/software/virtio-win-guest-tools.exe"]
    cd_files = ["./build_files/drivers/*", "./build_files/scripts/winrmConfig.bat", "./build_files/software/virtio-win-guest-tools.exe"]
    cd_content = {
      "autounattend.xml" = templatefile("./build_files/templates/unattend.pkrtpl", { password = var.winrm_password, cdrom_drive = var.cdrom_drive, index = lookup(var.image_index, var.template, "desktop") })
    }
    cd_label         = "Unattend"
    iso_storage_pool = "local"
    unmount          = true
    device           = "sata0"
  }

  network_adapters {
    model       = "e1000"
    bridge      = "vmbr0"
    mac_address = "A6:A6:A6:A6:A6:22"
  }

  disks {
    disk_size    = "60G"
    format       = "raw"
    storage_pool = "local-zfs"
    type         = "virtio"
    cache_mode   = "writeback"
  }

  # WinRM
  communicator   = "winrm"
  winrm_username = var.winrm_user
  winrm_password = var.winrm_password
  winrm_timeout  = "2h"
  winrm_port     = "5985"
  winrm_host     = var.winrm_host
  winrm_use_ssl  = false
  winrm_insecure = true

  # SSH
  # communicator = "ssh"
  # ssh_username = var.winrm_user
  # ssh_password = var.winrm_password
  # ssh_timeout = "2h"
  # ssh_clear_authorized_keys = "true"
  # ssh_host = var.winrm_host
  # ssh_port = 22

  # Packer Boot Commands
  boot_wait = "7s"
  boot_command = [
    "<enter>"
  ]
}

# VM Template Build Definition
build {
  name    = "Proxmox Build"
  sources = ["source.proxmox-iso.windows2022"]

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
    inline = [
      "C:\\Windows\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /unattend:unattend.xml"
    ]
  }
}