# Read system health check
path "sys/health"
{
  capabilities = ["read", "sudo"]
}

# List existing policies
path "sys/policies/acl"
{
  capabilities = ["list"]
}

# Create and manage ACL policies
path "sys/policies/acl/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage auth methods broadly across Vault
path "auth/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Create, update, and delete auth methods
path "sys/auth/*"
{
  capabilities = ["create", "update", "delete", "sudo"]
}

# List auth methods
path "sys/auth"
{
  capabilities = ["read"]
}

# List, create, update, and delete key/value secrets
path "secret/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage secrets engines
path "sys/mounts/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List existing secrets engines.
path "sys/mounts"
{
  capabilities = ["read", "list"]
}

# Work with pki secrets engine
path "pki*" {
  capabilities = [ "create", "read", "update", "delete", "list", "sudo", "patch" ]
}

# Work with kv2 secrets engine
path "kvv2*" {
  capabilities = [ "create", "read", "update", "delete", "list", "sudo", "patch" ]
}

# Work with transit secrets engine
path "transit*" {
  capabilities = [ "create", "read", "update", "delete", "list", "sudo", "patch" ]
}

# Work with SSH secrets engine
path "ssh*" {
  capabilities = [ "create", "read", "update", "delete", "list", "sudo", "patch" ]
}