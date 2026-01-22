ui = true
api_addr = "https://vault.local.andrecfaria.com:8200"
cluster_name = "vault"
disable_mlock = "true"
license_path = "/vault/config/vault.hclic"

storage "file" {
  path    = "/vault/data"
}

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = "false"
  tls_cert_file = "../certs/vault.crt"
  tls_key_file  = "../certs/vault.key"
}