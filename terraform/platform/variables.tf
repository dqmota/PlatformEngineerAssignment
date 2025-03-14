variable "organization_domain" {
  description = "The name of the organization"
  type        = string
}

variable "project_configs" {
  description = "The configuration for the projects"
  type = object({
    prefix = string
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
