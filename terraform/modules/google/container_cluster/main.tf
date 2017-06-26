resource "google_container_cluster" "govuk_google_container_cluster" {
  name               = "${var.name}"
  zone               = "${var.zone}"
  initial_node_count = "${var.initial_node_count}"
  node_version       = "${var.version}"
  network            = "${var.network}"
  subnetwork         = "${var.subnetwork}"
  additional_zones   = ["${var.additional_zones}"]

  master_auth {
    username = "${var.master_username}"
    password = "${var.master_password}"
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

