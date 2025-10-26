# Enable SSH Secrets Engine
resource "vault_mount" "ssh" {
  path        = "ssh"
  type        = "ssh"
  description = "SSH mount"
}