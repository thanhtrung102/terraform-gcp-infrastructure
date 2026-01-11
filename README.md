# Terraform GCP Infrastructure

Infrastructure-as-Code setup for Google Cloud Platform data engineering environment.

## Features

- BigQuery dataset with sample table
- Cloud Storage bucket with lifecycle rules
- Folder structure for data lake (raw/staging/processed)
- Environment labels and tagging
- Cost-optimized for GCP free tier

## Prerequisites

1. **Terraform CLI** >= 1.0
   ```bash
   # Windows (winget)
   winget install HashiCorp.Terraform

   # macOS (brew)
   brew install terraform
   ```

2. **Google Cloud SDK**
   ```bash
   # Windows (winget)
   winget install Google.CloudSDK

   # macOS (brew)
   brew install google-cloud-sdk
   ```

3. **GCP Project** with enabled APIs:
   - BigQuery API
   - Cloud Storage API
   - IAM API

## Quick Start

### 1. Set Up GCP

```bash
# Login to GCP
gcloud auth login

# Create or select project
gcloud projects create my-data-project --name="My Data Project"
gcloud config set project my-data-project

# Enable APIs
gcloud services enable bigquery.googleapis.com
gcloud services enable storage.googleapis.com
gcloud services enable iam.googleapis.com
```

### 2. Create Service Account

```bash
# Create service account
gcloud iam service-accounts create terraform-sa \
  --display-name="Terraform Service Account"

# Grant roles
PROJECT_ID=$(gcloud config get-value project)

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:terraform-sa@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/bigquery.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:terraform-sa@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/storage.admin"

# Generate credentials key
gcloud iam service-accounts keys create config/credentials.json \
  --iam-account=terraform-sa@$PROJECT_ID.iam.gserviceaccount.com
```

### 3. Configure Terraform

```bash
cd terraform

# Create tfvars from example
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values:
# - project_id = "your-project-id"
# - storage_bucket_name = "your-unique-bucket-name"
```

### 4. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply changes
terraform apply
```

### 5. Verify Deployment

```bash
# Check outputs
terraform output

# Verify in GCP Console
# - BigQuery: https://console.cloud.google.com/bigquery
# - Storage: https://console.cloud.google.com/storage
```

## Testing

### Upload Test Data

```bash
# Upload test.csv to raw folder
gsutil cp data/test.csv gs://YOUR_BUCKET_NAME/raw/

# List bucket contents
gsutil ls -r gs://YOUR_BUCKET_NAME/
```

### Load Data to BigQuery

```bash
# Load CSV to BigQuery table
bq load \
  --source_format=CSV \
  --skip_leading_rows=1 \
  data_warehouse.sample_users \
  gs://YOUR_BUCKET_NAME/raw/test.csv
```

### Query Data

```bash
# Run test query
bq query --use_legacy_sql=false \
  "SELECT * FROM \`YOUR_PROJECT.data_warehouse.sample_users\`"
```

## Project Structure

```
terraform-gcp/
├── terraform/
│   ├── main.tf              # Resource definitions
│   ├── variables.tf         # Input variables
│   ├── outputs.tf           # Output values
│   ├── versions.tf          # Provider versions
│   └── terraform.tfvars.example
├── config/
│   └── credentials.json     # Service account key (gitignored)
├── docs/
│   └── architecture.md      # Architecture documentation
├── data/
│   └── test.csv             # Sample test data
├── .gitignore
└── README.md
```

## Resources Created

| Resource | Type | Description |
|----------|------|-------------|
| `data_warehouse` | BigQuery Dataset | Main analytics dataset |
| `sample_users` | BigQuery Table | Sample table with user schema |
| Storage Bucket | GCS Bucket | Data lake with lifecycle rules |
| `/raw/` | GCS Folder | Landing zone for raw data |
| `/staging/` | GCS Folder | Transformation staging area |
| `/processed/` | GCS Folder | Clean data for analysis |

## Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `project_id` | Yes | - | GCP Project ID |
| `storage_bucket_name` | Yes | - | Globally unique bucket name |
| `region` | No | us-central1 | GCP region |
| `environment` | No | dev | Environment name |
| `bigquery_dataset_id` | No | data_warehouse | Dataset ID |
| `bigquery_location` | No | US | BigQuery location |
| `storage_location` | No | US | Storage location |

## Cleanup

```bash
# Destroy all resources
terraform destroy

# Confirm with 'yes'
```

## Cost Notes

This project uses GCP free tier resources:
- **BigQuery**: 10 GB storage, 1 TB queries/month
- **Cloud Storage**: 5 GB/month regional storage
- **IAM**: Free

Lifecycle rules auto-delete test data after 30 days.

## Troubleshooting

### "API not enabled" error
```bash
gcloud services enable bigquery.googleapis.com storage.googleapis.com
```

### "Permission denied" error
Ensure service account has BigQuery Admin and Storage Admin roles.

### "Bucket name already exists" error
Bucket names must be globally unique. Try a different name.

## License

MIT
