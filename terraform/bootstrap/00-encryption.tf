resource "google_folder" "security_parent" {
  display_name = "security"
  parent       = data.google_organization.default.id
}

# https://github.com/terraform-google-modules/terraform-google-project-factory/tree/main
module "security_project" {
  source = "terraform-google-modules/project-factory/google"

  name              = "Centralized KMS"
  project_id        = "${var.project_configs.prefix}-cryp-${data.google_organization.default.org_id}"
  random_project_id = false
  folder_id         = google_folder.security_parent.id
  billing_account   = var.project_configs.billing_account

  activate_apis = toset(concat(var.project_services, [
    "cloudkms.googleapis.com"
  ]))
}
