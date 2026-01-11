# Architecture Documentation

## Overview

This project provisions a foundational data infrastructure on Google Cloud Platform using Terraform.

## Components

### BigQuery Dataset

- **Purpose**: Central data warehouse for analytics
- **Dataset ID**: `data_warehouse`
- **Location**: US (multi-region)
- **Features**:
  - 30-day default table expiration
  - Environment labels for tracking
  - Sample users table with predefined schema

### Cloud Storage Bucket

- **Purpose**: Data lake for raw and processed files
- **Features**:
  - Uniform bucket-level access (security best practice)
  - Versioning enabled for data protection
  - Lifecycle rules:
    - After 7 days: Move to NEARLINE storage
    - After 30 days: Delete (for test data)
  - Folder structure:
    - `/raw/` - Landing zone for incoming data
    - `/staging/` - Transformation area
    - `/processed/` - Clean data ready for analysis

## Resource Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    GCP Project                               │
│                                                              │
│  ┌──────────────────────┐    ┌──────────────────────────┐   │
│  │     BigQuery         │    │    Cloud Storage         │   │
│  │                      │    │                          │   │
│  │  ┌────────────────┐  │    │  ┌────────────────────┐  │   │
│  │  │ data_warehouse │  │    │  │   data-lake-bucket │  │   │
│  │  │                │  │    │  │                    │  │   │
│  │  │ sample_users   │  │    │  │  /raw/             │  │   │
│  │  └────────────────┘  │    │  │  /staging/         │  │   │
│  │                      │    │  │  /processed/       │  │   │
│  └──────────────────────┘    │  └────────────────────┘  │   │
│                              └──────────────────────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Service Account (terraform-sa)           │   │
│  │                                                       │   │
│  │  Roles: BigQuery Admin, Storage Admin                 │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## Security

- Service account with minimal required permissions
- Credentials file excluded from version control
- Uniform bucket-level access (no per-object ACLs)

## Cost Management

All resources stay within GCP free tier:
- BigQuery: 10 GB storage, 1 TB queries/month
- Cloud Storage: 5 GB regional storage/month
- Lifecycle rules auto-delete test data

## Labels

All resources tagged with:
- `environment`: dev/staging/prod
- `managed_by`: terraform
- `project`: data-infrastructure
