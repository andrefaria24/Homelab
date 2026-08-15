terraform {
  required_version = ">= 1.10.0"

  required_providers {
    portainer = {
      source  = "portainer/portainer"
      version = "1.34.3"
    }
  }
}
