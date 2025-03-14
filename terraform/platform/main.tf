provider "google" {
  region = var.provider_config.region
  zone   = var.provider_config.zone
  default_labels = {
    "service" = "platform"
    "env"     = "production"
  }
}

data "google_client_config" "current" {
  provider = google
}

data "google_organization" "default" {
  domain = var.organization_domain
}
