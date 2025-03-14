data "google_project" "dropoff" {
  project_id = "${var.project_configs.prefix}-${local.stages.dropoff.suffix}-${data.google_organization.default.org_id}"
}

resource "google_pubsub_subscription" "dropoff_realtime" {
  project = data.google_project.dropoff.project_id

  name  = "dropoff-realtime-subscription"
  topic = "projects/pubsub-public-data/topics/taxirides-realtime"

  ack_deadline_seconds         = 30
  message_retention_duration   = "3600s" # 1 hour retention
  enable_exactly_once_delivery = true

  expiration_policy {
    ttl = "" # Never expires
  }

  labels = {
    stage = "dropoff"
  }
}

resource "google_pubsub_subscription_iam_binding" "dropoff_subscriber" {
  project = data.google_project.dropoff.project_id

  subscription = google_pubsub_subscription.dropoff_realtime.id
  role         = "roles/pubsub.subscriber"
  members = [
    "serviceAccount:project-service-account@${data.google_project.processing.project_id}.iam.gserviceaccount.com"
  ]
}