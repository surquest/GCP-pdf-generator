# Create storage buckets
resource "google_storage_bucket" "buckets" {

  for_each      = var.services.storage.buckets

  name           = jsondecode(templatefile(
    "../../config/naming.patterns.json",
    {
      solution = var.solution,
      services = var.services,
      GCP  = var.GCP
    }
  ))["storage"]["buckets"][each.key]

  location      = var.GCP.location
  uniform_bucket_level_access = true
  force_destroy = true

  lifecycle_rule {

      condition {
          age = each.value.lifecycle.condition.age  # days
      }
      action {
          type = each.value.lifecycle.action.type
          storage_class = each.value.lifecycle.action.storageClass
      }
  }

  labels = {

    solution = var.solution.slug
    env      = var.GCP.env
    
  }

}

# Summarize map of storage buckets and access
locals {
  storage_bucket_access = {
    for storageKey, storageVal in flatten([
      for key, value in var.services.storage.buckets: [
        for item in value.access: {
          idx             = "${key}.${item.role}.${item.type}.${item.key == null ? "-" : item.key}.${item.email == null ? "-" : item.email}"
          bucketKey       = key
          role            = item.role
          type            = item.type
          key             = item.key
          email           = item.email
        }
      ]
    ]): storageVal.idx => {
      bucketKey = storageVal.bucketKey
      role = storageVal.role
      type = storageVal.type
      key = storageVal.key
      email = storageVal.email
    }
  }
}

# Set storage bucket access
resource "google_storage_bucket_iam_member" "bucket_iam_binding" {

  for_each = local.storage_bucket_access

  bucket = google_storage_bucket.buckets[each.value.bucketKey].name
  role   = each.value.role
  member = each.value.email != null ? "${each.value.type}:${each.value.email}" : "${each.value.type}:${google_service_account.accounts[each.value.key].email}"

}