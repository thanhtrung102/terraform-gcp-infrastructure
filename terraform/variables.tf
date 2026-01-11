variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "credentials_file" {
  description = "Path to the GCP service account credentials JSON file"
  type        = string
  default     = "../config/credentials.json"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "bigquery_dataset_id" {
  description = "The ID of the BigQuery dataset"
  type        = string
  default     = "data_warehouse"
}

variable "bigquery_location" {
  description = "Location for BigQuery dataset"
  type        = string
  default     = "US"
}

variable "storage_bucket_name" {
  description = "Name for the Cloud Storage bucket (must be globally unique)"
  type        = string
}

variable "storage_location" {
  description = "Location for Cloud Storage bucket"
  type        = string
  default     = "US"
}

variable "default_table_expiration_ms" {
  description = "Default table expiration time in milliseconds (30 days = 2592000000)"
  type        = number
  default     = 2592000000
}
