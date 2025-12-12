# Enable SSH Secrets Engine
resource "vault_mount" "ssh" {
  path        = "ssh"
  type        = "ssh"
  description = "SSH mount"
}

resource "vault_ssh_secret_backend_ca" "main" {
  backend              = vault_mount.ssh.path
  generate_signing_key = true
}

resource "vault_ssh_secret_backend_role" "foo" {
  name                    = "linux_admins"
  backend                 = vault_mount.ssh.path
  key_type                = "ca"
  allow_user_certificates = true
  allowed_users           = var.allowed_ssh_users
  ttl                     = "1h"
  max_ttl                 = "24h"
  cidr_list               = var.ssh_cidr
}