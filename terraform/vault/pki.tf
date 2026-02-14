# Homelab Servers Role
resource "vault_pki_secret_backend_role" "homelab-servers" {
  backend                     = vault_mount.pki.path
  name                        = "homelab-servers"
  ttl                         = 31536000 # 10 Years
  allow_ip_sans               = true
  key_type                    = "rsa"
  key_bits                    = 2048
  allowed_domains             = var.allowed_domains
  allow_subdomains            = true
  allow_any_name              = false
  allow_bare_domains          = true
  allow_localhost             = false
  allow_wildcard_certificates = false
  client_flag                 = false
  require_cn                  = false

  ext_key_usage = ["ServerAuth"]
}