variable "organization_domain" {
  description = "The name of the organization"
  type        = string
}

variable "project_configs" {
  description = "The configuration for the projects"
  type = object({
    prefix          = string
    billing_account = string
    shared_vpc_host = string
  })
}

variable "location" {
  description = "A default location for all resources"
  type        = string
  default     = "eu"
}

variable "provider_config" {
  description = "The configuration for the provider"
  type = object({
    region = string
    zone   = string
  })
  default = {
    region = "europe-southwest1"
    zone   = "europe-southwest1-a"
  }
}

variable "project_services" {
  description = "List of core services enabled on all projects."
  type        = list(string)
  default = [
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "servicenetworking.googleapis.com",
    "serviceusage.googleapis.com",
    "stackdriver.googleapis.com",
  ]
}