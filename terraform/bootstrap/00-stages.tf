resource "google_folder" "stage_parent" {
  display_name = "platform"
  parent       = data.google_organization.default.id
}

# https://github.com/terraform-google-modules/terraform-google-project-factory/tree/main
module "stage_project" {
  source = "terraform-google-modules/project-factory/google"

  for_each = local.stages

  name              = each.value.name
  project_id        = "${var.project_configs.prefix}-${each.value.suffix}-${data.google_organization.default.org_id}"
  random_project_id = false
  folder_id         = google_folder.stage_parent.id
  billing_account   = var.project_configs.billing_account

  svpc_host_project_id = var.project_configs.shared_vpc_host
  shared_vpc_subnets = [
    "projects/${var.project_configs.shared_vpc_host}/regions/${data.google_client_config.current.region}/subnetworks/subnet-${each.key}",
  ]

  activate_apis = toset(concat(var.project_services, each.value.services))
}
