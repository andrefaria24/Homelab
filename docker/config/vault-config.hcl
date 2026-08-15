ui = true
api_addr = "https://vault.local.andrecfaria.com:8200"
cluster_name = "vault"
disable_mlock = "true"
#license_path = "/vault/config/vault.hclic"

storage "file" {
  path    = "/vault/data"
}

seal "awskms" {
  region     = "us-east-2"
  kms_key_id = "arn:aws:kms:us-east-2:ACCOUNT_ID:key/KEY_ID"
  access_key = "file:///run/secrets/vault_aws_access_key_id"
  secret_key = "file:///run/secrets/vault_aws_secret_access_key"
}

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = "true"
  tls_cert_file = "../certs/cert.pem"
  tls_key_file  = "../certs/key.pem"
}
