# Enable OIDC authentication
resource "vault_jwt_auth_backend" "oidc" {
  type               = "oidc"
  path               = "oidc"
  oidc_discovery_url = "https://accounts.google.com"
  oidc_client_id     = var.google_client_id
  oidc_client_secret = var.google_client_secret
  default_role       = "google-admin"

  tune {
    listing_visibility           = "hidden"
    allowed_response_headers     = []
    audit_non_hmac_request_keys  = []
    audit_non_hmac_response_keys = []
    passthrough_request_headers  = []
    default_lease_ttl            = "768h"
    max_lease_ttl                = "768h"
    token_type                   = "default-service"
  }
}

# Configure OIDC role for Google accounts
resource "vault_jwt_auth_backend_role" "google-admin" {
  backend               = vault_jwt_auth_backend.oidc.path
  role_name             = "google-admin"
  user_claim            = "sub"
  bound_audiences       = [var.google_client_id]
  allowed_redirect_uris = var.google_allowed_redirect_uris
  oidc_scopes           = ["email"]
  token_policies        = ["admin"]
  role_type             = "oidc"
}