#
# This creates:
#    - A GKE cluster (with a random password)
#    - Assigns a static IP for use by the cluster
#    - An A record pointing at the static IP
#

terraform {
  backend "gcs" {
  }
}

provider "google" {
  region      = "${var.google_region}"
  project     = "${var.google_project}"
}

resource "random_id" "master_password" {
  byte_length = "32"
}

module "govuk_cluster" {
  source             = "../../modules/google/container_cluster"
  name               = "${var.cluster_name}"
  zone               = "${var.cluster_zone}"
  network            = "${var.cluster_network}"
  network            = "${var.cluster_network}"
  subnetwork         = "${var.cluster_subnetwork}"
  master_username    = "${var.master_username}"
  master_password    = "${random_id.master_password.b64}"
  additional_zones   = "${var.additional_zones}"
  initial_node_count = "${var.initial_node_count}"
  version            = "${var.cluster_version}"
}

resource "google_compute_global_address" "frontend_static_ip" {
  name = "frontend-static-ip"
}

resource "google_dns_record_set" "frontend_a_record" {
  managed_zone = "${var.zone_name}"
  name         = "${var.frontend_dns_name}"
  type         = "A"
  ttl          = 300
  rrdatas      = ["${google_compute_global_address.frontend_static_ip.address}"]
}

# Uncomment when we increase the limit of static IPs per project (currently only 1)
#resource "google_compute_global_address" "backend_static_ip" {
#  name = "backend-static-ip"
#}

resource "google_dns_record_set" "backend_a_record" {
  managed_zone = "${var.zone_name}"
  name         = "${var.backend_dns_name}"
  type         = "A"
  ttl          = 300
#  rrdatas      = ["${google_compute_global_address.backend_static_ip.address}"]
  rrdatas      = ["${google_compute_global_address.frontend_static_ip.address}"]
}

