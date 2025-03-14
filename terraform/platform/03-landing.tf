data "google_project" "landing" {
  project_id = "${var.project_configs.prefix}-${local.stages.landing.suffix}-${data.google_organization.default.org_id}"
}

resource "google_bigquery_dataset" "landing_default" {
  project = data.google_project.landing.project_id

  dataset_id = "landing_default"
  location   = data.google_client_config.current.region

  labels = {
    stage = "landing"
  }
}

resource "google_bigquery_dataset_iam_binding" "landing_data_editor" {
  project = data.google_project.landing.project_id

  dataset_id = google_bigquery_dataset.landing_default.dataset_id
  role       = "roles/bigquery.dataEditor"
  members = [
    "serviceAccount:project-service-account@${data.google_project.processing.project_id}.iam.gserviceaccount.com",
  ]
}