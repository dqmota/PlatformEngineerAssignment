data "google_project" "processing" {
  project_id = "${var.project_configs.prefix}-${local.stages.processing.suffix}-${data.google_organization.default.org_id}"
}

data "google_service_account" "processing" {
  account_id = "project-service-account@${data.google_project.processing.project_id}.iam.gserviceaccount.com"
}

resource "google_storage_bucket" "processing_default" {
  project = data.google_project.processing.project_id

  name                        = "${var.project_configs.prefix}-${local.stages.processing.suffix}-default"
  location                    = data.google_client_config.current.region
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  force_destroy               = true
  soft_delete_policy {
    retention_duration_seconds = 0
  }

  labels = {
    stage = "processing"
  }
}

resource "google_composer_environment" "processing_default" {
  project = data.google_project.processing.project_id

  name   = "${local.stages.processing.suffix}-default"
  region = data.google_client_config.current.region
  config {
    software_config {
      image_version = "composer-3-airflow-2"
    }

    environment_size = "ENVIRONMENT_SIZE_SMALL"

    node_config {
      service_account = data.google_service_account.processing.name
      network         = "projects/sanguine-parsec-453303-j9/global/networks/data-platform-vpc"
      subnetwork      = "projects/sanguine-parsec-453303-j9/regions/europe-southwest1/subnetworks/subnet-processing"
    }
  }

  labels = {
    stage = "processing"
  }
}

resource "google_storage_bucket_iam_binding" "processing_admin" {
  bucket = google_storage_bucket.processing_default.name
  role   = "roles/storage.admin"
  members = [
    "serviceAccount:${data.google_service_account.processing.email}"
  ]
}

# https://cloud.google.com/dataflow/docs/concepts/access-control#roles
resource "google_project_iam_member" "processing_impersonate_itself" {
  project = data.google_project.processing.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${data.google_service_account.processing.email}"
}

resource "google_project_iam_member" "processing_dataflow_admin" {
  project = data.google_project.processing.project_id
  role    = "roles/dataflow.admin"
  member  = "serviceAccount:${data.google_service_account.processing.email}"
}

resource "google_project_iam_member" "processing_dataflow_worker" {
  project = data.google_project.processing.project_id
  role    = "roles/dataflow.worker"
  member  = "serviceAccount:${data.google_service_account.processing.email}"
}

resource "google_project_iam_member" "processing_composer_worker" {
  project = data.google_project.processing.project_id
  role    = "roles/composer.worker"
  member  = "serviceAccount:${data.google_service_account.processing.email}"
}