resource "tfe_organization" "default" {
  name  = var.tfe_organization
  email = var.tfe_email
}