output "project_id" {
  description = "The GCP project ID"
  value       = var.project_id
}

output "bigquery_dataset_id" {
  description = "The BigQuery dataset ID"
  value       = google_bigquery_dataset.main.dataset_id
}

output "bigquery_dataset_location" {
  description = "The BigQuery dataset location"
  value       = google_bigquery_dataset.main.location
}

output "bigquery_table_id" {
  description = "The sample BigQuery table ID"
  value       = "${var.project_id}.${google_bigquery_dataset.main.dataset_id}.${google_bigquery_table.sample_users.table_id}"
}

output "storage_bucket_name" {
  description = "The Cloud Storage bucket name"
  value       = google_storage_bucket.data_lake.name
}

output "storage_bucket_url" {
  description = "The Cloud Storage bucket URL"
  value       = "gs://${google_storage_bucket.data_lake.name}"
}

output "storage_bucket_self_link" {
  description = "The Cloud Storage bucket self link"
  value       = google_storage_bucket.data_lake.self_link
}
