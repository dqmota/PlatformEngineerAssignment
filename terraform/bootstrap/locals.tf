locals {
  stages = {
    dropoff = {
      name   = "Drop-off Stage"
      suffix = "drop"
      services = [
        "pubsub.googleapis.com",
        "storage.googleapis.com",
        "storage-component.googleapis.com",
      ]
    }
    processing = {
      name   = "Processing Stage"
      suffix = "proc"
      services = [
        "compute.googleapis.com",
        "dataflow.googleapis.com",
        "composer.googleapis.com",
        "storage.googleapis.com",
        "storage-component.googleapis.com",
      ]
    }
    landing = {
      name   = "Landing Stage"
      suffix = "land"
      services = [
        "bigquery.googleapis.com",
        "bigquerystorage.googleapis.com",
        "storage.googleapis.com",
        "storage-component.googleapis.com",
      ]
    }
    pickup = {
      name   = "Pick-up Stage"
      suffix = "pick"
      services = [
        "pubsub.googleapis.com",
        "storage.googleapis.com",
        "storage-component.googleapis.com",
      ]
    }
  }
}