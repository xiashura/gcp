resource "google_compute_subnetwork" "network-with-private-secondary-ip-ranges" {
  name          = var.name
  project       = var.project
  ip_cidr_range = "10.2.0.0/16"
  region        = var.project
  network       = google_compute_network.custom-test.id
  secondary_ip_range {
    range_name    = "tf-test-secondary-range-update1"
    ip_cidr_range = "192.168.10.0/24"
  }
}

resource "google_compute_network" "custom-test" {
  name                    = "test-network"
  auto_create_subnetworks = false
}
