resource "tfe_project" "default" {
  organization = tfe_organization.default.name
  name         = "Default Project"
}

resource "tfe_project" "onprem" {
  organization = tfe_organization.default.name
  name         = "On-premises Infrastructure"
}