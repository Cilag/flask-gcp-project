terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# ===========================================
# ARTIFACT REGISTRY
# ===========================================
resource "google_artifact_registry_repository" "flask_repo" {
  location      = var.region
  repository_id = var.artifact_repo_name
  description   = "Docker repository for Flask application"
  format        = "DOCKER"
}

# ===========================================
# SERVICE ACCOUNTS & IAM
# ===========================================

# Service Account pour GKE
resource "google_service_account" "gke_sa" {
  account_id   = "gke-service-account"
  display_name = "Service Account for GKE Workloads"
  description  = "Service account used by GKE pods"
}

# Service Account pour CI/CD (GitHub Actions)
resource "google_service_account" "cicd_sa" {
  account_id   = "cicd-service-account"
  display_name = "Service Account for CI/CD Pipeline"
  description  = "Service account used by GitHub Actions"
}

# IAM Bindings pour le Service Account GKE
resource "google_project_iam_member" "gke_container_admin" {
  project = var.project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

resource "google_project_iam_member" "gke_artifact_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

# IAM Bindings pour le Service Account CI/CD
resource "google_project_iam_member" "cicd_container_developer" {
  project = var.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.cicd_sa.email}"
}

resource "google_project_iam_member" "cicd_artifact_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.cicd_sa.email}"
}

resource "google_project_iam_member" "cicd_storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.cicd_sa.email}"
}

# ===========================================
# ENABLE REQUIRED APIs
# ===========================================
resource "google_project_service" "container_api" {
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "artifactregistry_api" {
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iam_api" {
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}
