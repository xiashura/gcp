resource "google_service_account" "service_account" {
  account_id   = "docker-registry-admin-${var.suffix-name-account-admin}"
  display_name = "Docker Registry Admin"
  project      = var.project
}

resource "google_container_registry" "registry" {
  project  = var.project
  location = var.location
}

resource "google_storage_bucket_iam_member" "admin-registry" {
  bucket = google_container_registry.registry.id
  role   = "roles/containerregistry.ServiceAgent"
  member = google_service_account.service_account.member
}

resource "google_service_account_key" "key-admin-registry" {
  service_account_id = google_service_account.service_account.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}
