resource "tfe_organization" "default" {
  name  = var.tfe_organization
  email = var.tfe_email
}

resource "tfe_project" "default" {
  organization = tfe_organization.default.name
  name         = "Default Project"
}