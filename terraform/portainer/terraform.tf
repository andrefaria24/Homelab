terraform {
  # Write-only resource arguments (data_wo) require Terraform 1.11 or later.
  required_version = ">= 1.11.0"

  required_providers {
    portainer = {
      source  = "portainer/portainer"
      version = "1.34.3"
    }
  }
}
