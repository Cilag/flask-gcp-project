output "gke_service_account_email" {
  description = "Email of the GKE service account"
  value       = google_service_account.gke_sa.email
}

output "cicd_service_account_email" {
  description = "Email of the CI/CD service account"
  value       = google_service_account.cicd_sa.email
}

output "artifact_registry_url" {
  description = "URL of the Artifact Registry repository"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.flask_repo.repository_id}"
}
