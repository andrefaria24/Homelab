# Enable Transit Secrets Engine
resource "vault_mount" "transit" {
  path        = "transit"
  type        = "transit"
  description = "Transit mount"

  options = {
    convergent_encryption = false
  }
}