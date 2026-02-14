# Admin policy
resource "vault_policy" "admin" {
  name   = "admin"
  policy = file("policies/admin-policy.hcl")
}