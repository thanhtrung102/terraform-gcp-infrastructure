# Provider Configuration
provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = file(var.credentials_file)
}

# Local values for common tags/labels
locals {
  common_labels = {
    environment = var.environment
    managed_by  = "terraform"
    project     = "data-infrastructure"
  }
}

# =============================================================================
# BigQuery Resources
# =============================================================================

# BigQuery Dataset
resource "google_bigquery_dataset" "main" {
  dataset_id                 = var.bigquery_dataset_id
  friendly_name              = "Data Warehouse"
  description                = "Main data warehouse for analytics workloads"
  location                   = var.bigquery_location
  default_table_expiration_ms = var.default_table_expiration_ms

  labels = local.common_labels
}

# Sample BigQuery Table
resource "google_bigquery_table" "sample_users" {
  dataset_id          = google_bigquery_dataset.main.dataset_id
  table_id            = "sample_users"
  description         = "Sample users table for testing"
  deletion_protection = false

  labels = local.common_labels

  schema = jsonencode([
    {
      name        = "id"
      type        = "INTEGER"
      mode        = "REQUIRED"
      description = "Unique user identifier"
    },
    {
      name        = "name"
      type        = "STRING"
      mode        = "REQUIRED"
      description = "User full name"
    },
    {
      name        = "email"
      type        = "STRING"
      mode        = "NULLABLE"
      description = "User email address"
    },
    {
      name        = "created_at"
      type        = "DATE"
      mode        = "NULLABLE"
      description = "Account creation date"
    }
  ])
}

# =============================================================================
# Cloud Storage Resources
# =============================================================================

# Cloud Storage Bucket
resource "google_storage_bucket" "data_lake" {
  name                        = var.storage_bucket_name
  location                    = var.storage_location
  force_destroy               = true
  uniform_bucket_level_access = true

  labels = local.common_labels

  # Versioning for data protection
  versioning {
    enabled = true
  }

  # Lifecycle rules to manage costs
  lifecycle_rule {
    condition {
      age = 7
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
}

# Folder structure using placeholder objects
resource "google_storage_bucket_object" "raw_folder" {
  name    = "raw/.keep"
  content = "# Raw data landing zone"
  bucket  = google_storage_bucket.data_lake.name
}

resource "google_storage_bucket_object" "staging_folder" {
  name    = "staging/.keep"
  content = "# Staging area for transformations"
  bucket  = google_storage_bucket.data_lake.name
}

resource "google_storage_bucket_object" "processed_folder" {
  name    = "processed/.keep"
  content = "# Processed data ready for analysis"
  bucket  = google_storage_bucket.data_lake.name
}

# =============================================================================
# IAM Bindings (for service account roles)
# =============================================================================

# BigQuery Admin role for the Terraform service account
resource "google_project_iam_member" "bigquery_admin" {
  project = var.project_id
  role    = "roles/bigquery.admin"
  member  = "serviceAccount:terraform-sa@${var.project_id}.iam.gserviceaccount.com"
}

# Storage Admin role for the Terraform service account
resource "google_project_iam_member" "storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:terraform-sa@${var.project_id}.iam.gserviceaccount.com"
}

# Project Viewer role for the Terraform service account
resource "google_project_iam_member" "project_viewer" {
  project = var.project_id
  role    = "roles/viewer"
  member  = "serviceAccount:terraform-sa@${var.project_id}.iam.gserviceaccount.com"
}
