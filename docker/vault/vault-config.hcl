ui = true
api_addr = "http://vault.local.andrecfaria.com:8200"
disable_mlock = "true"

storage "file" {
  path    = "/vault/data"
}

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = "true"
}