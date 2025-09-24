# Enable KV-V2 Secrets Engine
resource "vault_mount" "kvv2" {
  path        = "kvv2"
  type        = "kv"
  options     = { version = "2" }
  description = "Key-Value V2 mount"
}