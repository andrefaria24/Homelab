# Enable PKI secrets engine
resource "vault_mount" "pki" {
  path        = "pki"
  type        = "pki"
  description = "Root PKI mount"

  default_lease_ttl_seconds = 31536000  # 1 Year
  max_lease_ttl_seconds     = 315360000 # 10 Years
}

# Create Vault root certificate
resource "vault_pki_secret_backend_root_cert" "pki_root" {
  backend     = vault_mount.pki.path
  type        = "internal"
  common_name = var.cn_root
  ttl         = 315360000 # 10 Years
  issuer_name = var.issuer_name
}

resource "vault_pki_secret_backend_issuer" "pki_root" {
  backend                        = vault_mount.pki.path
  issuer_ref                     = vault_pki_secret_backend_root_cert.pki_root.issuer_id
  issuer_name                    = vault_pki_secret_backend_root_cert.pki_root.issuer_name
  revocation_signature_algorithm = "SHA256WithRSA"
}

# Create root CA role
resource "vault_pki_secret_backend_role" "root_role" {
  backend          = vault_mount.pki.path
  name             = "root-certs"
  ttl              = 31536000 # 10 Years
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  allowed_domains  = var.allowed_domains
  allow_subdomains = true
  allow_any_name   = true
}

# Configure root CA and CRL URLs
resource "vault_pki_secret_backend_config_urls" "root_config_urls" {
  backend                 = vault_mount.pki.path
  issuing_certificates    = ["${var.vault_address}/v1/pki/ca"]
  crl_distribution_points = ["${var.vault_address}/v1/pki/crl"]
}

# Enable intermediate authority PKI secrets engine
resource "vault_mount" "pki_int" {
  path        = "pki_int"
  type        = "pki"
  description = "Intermediate PKI mount"

  default_lease_ttl_seconds = 31536000  # 1 Year
  max_lease_ttl_seconds     = 315360000 # 10 Years
}

# Generate an intermediate
resource "vault_pki_secret_backend_intermediate_cert_request" "csr-request" {
  backend     = vault_mount.pki_int.path
  type        = "internal"
  common_name = "${var.cn_root} Intermediate Authority"
}

# Sign with the root CA private key & save the generated certificate
resource "vault_pki_secret_backend_root_sign_intermediate" "intermediate" {
  backend     = vault_mount.pki.path
  common_name = var.cn_intermediate
  csr         = vault_pki_secret_backend_intermediate_cert_request.csr-request.csr
  format      = "pem_bundle"
  ttl         = 315360000 # 10 Years
  issuer_ref  = vault_pki_secret_backend_root_cert.pki_root.issuer_id
}

# Import cert back to Vault
resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate" {
  backend     = vault_mount.pki_int.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate
}

# Manually imported
resource "vault_pki_secret_backend_issuer" "intermediate" {
  backend    = vault_mount.pki_int.path
  issuer_ref = "90ffcf38-7eee-a9d5-0961-ba4392ab3f18"
}

# Create intermediate CA role
resource "vault_pki_secret_backend_role" "intermediate_role" {
  backend          = vault_mount.pki_int.path
  issuer_ref       = vault_pki_secret_backend_issuer.intermediate.issuer_ref
  name             = var.cn_intermediate_role_name
  ttl              = 31536000 # 10 Years
  max_ttl          = 31536000 # 10 Years
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  allowed_domains  = var.allowed_domains
  allow_subdomains = true
}