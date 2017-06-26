variable "name" {
  type        = "string"
  description = "A unique name for the network"
}

variable "cidr" {
  type        = "string"
  description = "(NOT IN USE) Network IP address range, represented as a CIDR block. Only used to enable internal traffic in the firewall"
}

variable "trusted_ips" {
  type        = "list"
  description = "List of trusted IPs to enable access to Google instances"
}

variable "public_subnetworks_cidrs" {
  type        = "map"
  description = "Map containing public subnet names and CIDR associated"
}

variable "public_subnetworks_regions" {
  type        = "map"
  description = "Map containing public subnet names and region associated"
}

resource "google_compute_network" "govuk_network" {
  name                    = "${var.name}"
  auto_create_subnetworks = false
}

module "govuk_subnetwork_public" {
  source             = "./public_subnetwork"
  subnetwork_cidrs   = "${var.public_subnetworks_cidrs}"
  subnetwork_regions = "${var.public_subnetworks_regions}"
  network            = "${google_compute_network.govuk_network.self_link}"
}

resource "google_compute_firewall" "allow-ssh" {
  name    = "${var.name}-allow-ssh"
  network = "${google_compute_network.govuk_network.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = "${var.trusted_ips}"
}

resource "google_compute_firewall" "allow-icmp" {
  name    = "${var.name}-allow-icmp"
  network = "${google_compute_network.govuk_network.name}"

  allow {
    protocol = "icmp"
  }

  source_ranges = "${var.trusted_ips}"
}

output "network_name" {
  value = "${google_compute_network.govuk_network.name}"
}

output "subnetwork_public_names" {
  value = "${module.govuk_subnetwork_public.subnetwork_public_names}"
}

