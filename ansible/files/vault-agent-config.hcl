vault {
  address = "http://faria-vault.local.andrecfaria.com:8200"
  retry {
    num_retries = 3
  }
}

cache {
  // Enables caching
}

api_proxy {
  use_auto_auth_token = false
}

listener "tcp" {
  address = "127.0.0.1:8100"
  tls_disable = true
}

template {
  source = "/etc/vault/server.key.ctmpl"
  destination = "/etc/vault/server.key"
}

template {
  source = "/etc/vault/server.crt.ctmpl"
  destination = "/etc/vault/server.crt"
}