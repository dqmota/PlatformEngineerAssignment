data "google_project" "dropoff" {
  project_id = "${var.project_configs.prefix}-${local.stages.dropoff.suffix}-${data.google_organization.default.org_id}"
}

data "google_service_account" "dropoff" {
  account_id = "project-service-account@${data.google_project.dropoff.project_id}.iam.gserviceaccount.com"
}

resource "google_pubsub_subscription" "dropoff_realtime" {
  project = data.google_project.dropoff.project_id

  name  = "dropoff-realtime-subscription"
  topic = "projects/pubsub-public-data/topics/taxirides-realtime"

  ack_deadline_seconds         = 30
  message_retention_duration   = "3600s" # 1 hour retention
  enable_exactly_once_delivery = false

  expiration_policy {
    ttl = "" # Never expires
  }

  labels = {
    stage = "dropoff"
  }
}

resource "google_pubsub_topic" "dropoff_location_service" {
  project = data.google_project.dropoff.project_id
  name    = "dropoff-location-service"

  labels = {
    stage = "dropoff"
  }
}
resource "google_storage_bucket" "dropoff_location_service" {
  project = data.google_project.dropoff.project_id

  name                        = "${var.project_configs.prefix}-${local.stages.dropoff.suffix}-location-service"
  location                    = data.google_client_config.current.region
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  force_destroy               = true
  soft_delete_policy {
    retention_duration_seconds = 0
  }

  labels = {
    stage = "dropoff"
  }
}

resource "google_pubsub_subscription" "dropoff_location_service" {
  project = data.google_project.dropoff.project_id

  name  = "dropoff-location-service-storage"
  topic = google_pubsub_topic.dropoff_location_service.id

  cloud_storage_config {
    bucket = google_storage_bucket.dropoff_location_service.name

    filename_datetime_format = "YYYY/MM/DD/hh/mm_ssZ"
    filename_suffix = ".avro"

    max_duration = "300s"
    max_messages = 1000

    avro_config {
      write_metadata   = false
      use_topic_schema = false
    }

    service_account_email = data.google_service_account.dropoff.email
  }

  labels = {
    stage = "dropoff"
  }

  depends_on = [
    google_pubsub_topic.dropoff_location_service,
    google_storage_bucket.dropoff_location_service,
    google_storage_bucket_iam_binding.dropoff_location_service_admin,
  ]
}

# https://cloud.google.com/pubsub/docs/access-control#roles
resource "google_pubsub_subscription_iam_binding" "dropoff_realtime_subscriber" {
  project = data.google_project.dropoff.project_id

  subscription = google_pubsub_subscription.dropoff_realtime.id
  role         = "roles/pubsub.subscriber"
  members = [
    "serviceAccount:${data.google_service_account.processing.email}"
  ]
}

resource "google_pubsub_subscription_iam_binding" "dropoff_realtime_viewer" {
  project = data.google_project.dropoff.project_id

  subscription = google_pubsub_subscription.dropoff_realtime.id
  role         = "roles/pubsub.viewer"
  members = [
    "serviceAccount:${data.google_service_account.processing.email}"
  ]
}

resource "google_pubsub_topic_iam_binding" "dropoff_location_service_publisher" {
  project = data.google_project.dropoff.project_id

  topic = google_pubsub_topic.dropoff_location_service.id
  role  = "roles/pubsub.publisher"
  members = [
    "serviceAccount:${data.google_service_account.dropoff.email}"
  ]
}

resource "google_storage_bucket_iam_binding" "dropoff_location_service_admin" {
  bucket = google_storage_bucket.dropoff_location_service.name
  role   = "roles/storage.admin"
  members = [
    "serviceAccount:${data.google_service_account.dropoff.email}"
  ]
}

resource "google_storage_bucket_iam_binding" "dropoff_location_service_viewer" {
  bucket = google_storage_bucket.dropoff_location_service.name
  role   = "roles/storage.objectViewer"
  members = [
    "serviceAccount:${data.google_service_account.processing.email}"
  ]
}