# Enable Userpass authentication
resource "vault_auth_backend" "userpass" {
  type = "userpass"

  tune {
    max_lease_ttl      = "1m"
    listing_visibility = "unauth"
  }
}

# Create admin policy
resource "vault_policy" "admin" {
  name   = "admin"
  policy = file("policies/admin-policy.hcl")
}

# Create admin user for userpass auth
resource "vault_generic_endpoint" "admin" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/${var.admin_username}"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "policies": ["admin"],
  "password": "${var.admin_password}"
}
EOT
}

# Enable PKI secret engine
resource "vault_mount" "pki" {
  path        = "pki"
  type        = "pki"

  default_lease_ttl_seconds = 0
  max_lease_ttl_seconds     = 315360000
}

# Create homelab PKI role
resource "vault_pki_secret_backend_role" "homelab" {
  allow_any_name   = true
  backend          = vault_mount.pki.path
  name             = "homelab"
  ttl              = 0
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 2048
  allowed_domains  = var.pki_allowed_domains
  allow_subdomains = true

  country = var.cert_country
  province = var.cert_province
  locality = var.cert_locality
  street_address = var.cert_street_address
  postal_code = var.cert_postal_code
}

# Enable transit secret engine
resource "vault_mount" "transit" {
  path        = "transit"
  type        = "transit"
}