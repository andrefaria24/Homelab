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

# Enable transit secret engine
resource "vault_mount" "transit" {
  path        = "transit"
  type        = "transit"
}