ui = true
api_addr = "https://vault.local.andrecfaria.com:8200"
cluster_name = "faria-vault"
disable_mlock = "true"

storage "file" {
  path    = "/vault/data"
}

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = "false"
  tls_cert_file = "/certs/server.crt"
  tls_key_file  = "/certs/server.key"
}