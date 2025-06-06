locals {
  cert_ttl      = 63072000 # 2 Years
  cert_location = "./certs/"
}

# Vault
resource "vault_pki_secret_backend_cert" "vault" {
  issuer_ref  = vault_pki_secret_backend_issuer.intermediate.issuer_ref
  backend     = vault_pki_secret_backend_role.intermediate_role.backend
  name        = vault_pki_secret_backend_role.intermediate_role.name
  common_name = "vault.${var.cn_intermediate}"
  ttl         = 31536000 # 10 Years
  revoke      = true
}

resource "local_file" "vault_pvt_key" {
  content  = vault_pki_secret_backend_cert.vault.private_key
  filename = "${local.cert_location}${vault_pki_secret_backend_cert.vault.common_name}.key"
}

resource "local_file" "vault_pub_key" {
  content  = vault_pki_secret_backend_cert.vault.certificate
  filename = "${local.cert_location}${vault_pki_secret_backend_cert.vault.common_name}.crt"
}

# Pi-hole
resource "vault_pki_secret_backend_cert" "pihole" {
  issuer_ref  = vault_pki_secret_backend_issuer.intermediate.issuer_ref
  backend     = vault_pki_secret_backend_role.intermediate_role.backend
  name        = vault_pki_secret_backend_role.intermediate_role.name
  common_name = "faria-pi.${var.cn_intermediate}"
  ttl         = local.cert_ttl
  revoke      = true
}

resource "local_file" "pihole_pvt_key" {
  content  = vault_pki_secret_backend_cert.pihole.private_key
  filename = "${local.cert_location}${vault_pki_secret_backend_cert.pihole.common_name}.key"
}

resource "local_file" "pihole_pub_key" {
  content  = vault_pki_secret_backend_cert.pihole.certificate
  filename = "${local.cert_location}${vault_pki_secret_backend_cert.pihole.common_name}.crt"
}

# Portainer
resource "vault_pki_secret_backend_cert" "portainer" {
  issuer_ref  = vault_pki_secret_backend_issuer.intermediate.issuer_ref
  backend     = vault_pki_secret_backend_role.intermediate_role.backend
  name        = vault_pki_secret_backend_role.intermediate_role.name
  common_name = "portainer.${var.cn_intermediate}"
  ttl         = local.cert_ttl
  revoke      = true
}

resource "local_file" "portainer_pvt_key" {
  content  = vault_pki_secret_backend_cert.portainer.private_key
  filename = "${local.cert_location}${vault_pki_secret_backend_cert.portainer.common_name}.key"
}

resource "local_file" "portainer_pub_key" {
  content  = vault_pki_secret_backend_cert.portainer.certificate
  filename = "${local.cert_location}${vault_pki_secret_backend_cert.portainer.common_name}.crt"
}

# UptimeKuma
resource "vault_pki_secret_backend_cert" "uptimekuma" {
  issuer_ref  = vault_pki_secret_backend_issuer.intermediate.issuer_ref
  backend     = vault_pki_secret_backend_role.intermediate_role.backend
  name        = vault_pki_secret_backend_role.intermediate_role.name
  common_name = "monitoring.${var.cn_intermediate}"
  ttl         = local.cert_ttl
  revoke      = true
}

resource "local_file" "uptimekuma_pvt_key" {
  content  = vault_pki_secret_backend_cert.uptimekuma.private_key
  filename = "${local.cert_location}${vault_pki_secret_backend_cert.uptimekuma.common_name}.key"
}

resource "local_file" "uptimekuma_pub_key" {
  content  = vault_pki_secret_backend_cert.uptimekuma.certificate
  filename = "${local.cert_location}${vault_pki_secret_backend_cert.uptimekuma.common_name}.crt"
}

# Router (RT-AX86U Pro)
resource "vault_pki_secret_backend_cert" "router" {
  issuer_ref  = vault_pki_secret_backend_issuer.intermediate.issuer_ref
  backend     = vault_pki_secret_backend_role.intermediate_role.backend
  name        = vault_pki_secret_backend_role.intermediate_role.name
  common_name = "faria-router.${var.cn_intermediate}"
  ttl         = local.cert_ttl
  revoke      = true
}

resource "local_file" "router_pvt_key" {
  content  = vault_pki_secret_backend_cert.router.private_key
  filename = "${local.cert_location}${vault_pki_secret_backend_cert.router.common_name}.key"
}

resource "local_file" "router_pub_key" {
  content  = vault_pki_secret_backend_cert.router.certificate
  filename = "${local.cert_location}${vault_pki_secret_backend_cert.router.common_name}.crt"
}

# Plex
resource "vault_pki_secret_backend_cert" "plex" {
  issuer_ref  = vault_pki_secret_backend_issuer.intermediate.issuer_ref
  backend     = vault_pki_secret_backend_role.intermediate_role.backend
  name        = vault_pki_secret_backend_role.intermediate_role.name
  common_name = "faria-plex.${var.cn_intermediate}"
  ttl         = local.cert_ttl
  revoke      = true
}

resource "local_file" "plex_pvt_key" {
  content  = vault_pki_secret_backend_cert.plex.private_key
  filename = "${local.cert_location}${vault_pki_secret_backend_cert.plex.common_name}.key"
}

resource "local_file" "plex_pub_key" {
  content  = vault_pki_secret_backend_cert.plex.certificate
  filename = "${local.cert_location}${vault_pki_secret_backend_cert.plex.common_name}.crt"
}

# Proxmox
resource "vault_pki_secret_backend_cert" "proxmox" {
  issuer_ref  = vault_pki_secret_backend_issuer.intermediate.issuer_ref
  backend     = vault_pki_secret_backend_role.intermediate_role.backend
  name        = vault_pki_secret_backend_role.intermediate_role.name
  common_name = "faria-proxmox.${var.cn_intermediate}"
  ttl         = local.cert_ttl
  revoke      = true
}

resource "local_file" "proxmox_pvt_key" {
  content  = vault_pki_secret_backend_cert.proxmox.private_key
  filename = "${local.cert_location}${vault_pki_secret_backend_cert.proxmox.common_name}.key"
}

resource "local_file" "proxmox_pub_key" {
  content  = vault_pki_secret_backend_cert.proxmox.certificate
  filename = "${local.cert_location}${vault_pki_secret_backend_cert.proxmox.common_name}.crt"
}

# Synology NAS
resource "vault_pki_secret_backend_cert" "nas" {
  issuer_ref  = vault_pki_secret_backend_issuer.intermediate.issuer_ref
  backend     = vault_pki_secret_backend_role.intermediate_role.backend
  name        = vault_pki_secret_backend_role.intermediate_role.name
  common_name = "faria-nas.${var.cn_intermediate}"
  ttl         = local.cert_ttl
  revoke      = true
}

resource "local_file" "nas" {
  content  = vault_pki_secret_backend_cert.nas.private_key
  filename = "${local.cert_location}${vault_pki_secret_backend_cert.nas.common_name}.key"
}

resource "local_file" "nas_pub_key" {
  content  = vault_pki_secret_backend_cert.nas.certificate
  filename = "${local.cert_location}${vault_pki_secret_backend_cert.nas.common_name}.crt"
}