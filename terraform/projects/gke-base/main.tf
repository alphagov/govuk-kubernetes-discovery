#
# This creates:
#    - A network
#    - Firewall rules (allow SSH, RDP, ICMP)
#    - A static IP
#    - An A record for the static IP mapping to gke.integration.publishing.service.gov.uk
#

terraform {
  backend "gcs" {
  }
}

provider "google" {
  region      = "${var.google_region}"
  project     = "${var.google_project}"
}

module "network" {
  source                     = "../../modules/google/network"
  name                       = "${var.network_name}"
  cidr                       = "${var.network_cidr}"
  trusted_ips                = "${var.office_ips}"
  public_subnetworks_cidrs   = "${var.public_subnetworks_cidrs}"
  public_subnetworks_regions = "${var.public_subnetworks_regions}"
}
