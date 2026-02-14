# Full administrative access to all Vault resources
path "*" {
  capabilities = [
    "create",
    "read",
    "update",
    "delete",
    "list",
    "sudo"
  ]
}