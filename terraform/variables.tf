variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region for resources"
  type        = string
  default     = "europe-west1"
}

variable "zone" {
  description = "GCP zone for GKE cluster"
  type        = string
  default     = "europe-west1-b"
}

variable "artifact_repo_name" {
  description = "Name of the Artifact Registry repository"
  type        = string
  default     = "flask-repo"
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "flask-cluster"
}
