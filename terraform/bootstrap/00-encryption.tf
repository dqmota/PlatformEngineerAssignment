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

resource "google_kms_key_ring" "default" {
  name     = "centralized-keyring"
  project  = module.security_project.project_id
  location = data.google_client_config.current.region
}

resource "google_kms_crypto_key" "service-key" {
  for_each = toset(local.services_kms)

  name            = "${each.key}-key"
  key_ring        = google_kms_key_ring.default.id
  rotation_period = "7776000s" # 90 days
  purpose         = "ENCRYPT_DECRYPT"

  lifecycle {
    prevent_destroy = true
  }
}
