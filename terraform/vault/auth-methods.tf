# Enable Userpass authentication
resource "vault_auth_backend" "userpass" {
  type = "userpass"
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

# Enable OIDC authentication
resource "vault_jwt_auth_backend" "oidc" {
  type               = "oidc"
  path               = "oidc"
  oidc_discovery_url = "https://accounts.google.com"
  oidc_client_id     = var.google_client_id
  oidc_client_secret = var.google_client_secret
  default_role       = "google"

  tune {
    listing_visibility           = "unauth"
    allowed_response_headers     = []
    audit_non_hmac_request_keys  = []
    audit_non_hmac_response_keys = []
    passthrough_request_headers  = []
    default_lease_ttl            = "768h"
    max_lease_ttl                = "30m"
    token_type                   = "default-service"
  }
}

# Configure OIDC role for Google accounts
resource "vault_jwt_auth_backend_role" "google" {
  backend               = vault_jwt_auth_backend.oidc.path
  role_name             = "google"
  user_claim            = "sub"
  bound_audiences       = [var.google_client_id]
  allowed_redirect_uris = var.google_allowed_redirect_uris
  token_policies        = ["admin"]
  role_type             = "oidc"
}