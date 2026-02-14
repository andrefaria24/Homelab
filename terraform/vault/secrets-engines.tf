# KV-V2 Secrets Engine
resource "vault_mount" "kvv2" {
  path               = "kv"
  type               = "kv"
  options            = { version = "2" }
  listing_visibility = "hidden"
}

# PKI secrets engine
resource "vault_mount" "pki" {
  path               = replace("${var.cn_root}-root", ".", "-")
  type               = "pki"
  listing_visibility = "hidden"
}