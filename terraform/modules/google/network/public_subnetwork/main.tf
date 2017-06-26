variable "network" {
  type = "string"
}

variable "subnetwork_cidrs" {
  type = "map"
}

variable "subnetwork_regions" {
  type = "map"
}

resource "google_compute_subnetwork" "subnetwork_public" {
  count         = "${length(keys(var.subnetwork_cidrs))}"
  name          = "${element(keys(var.subnetwork_cidrs), count.index)}"
  ip_cidr_range = "${element(values(var.subnetwork_cidrs), count.index)}"
  network       = "${var.network}"
  region        = "${lookup(var.subnetwork_regions, element(keys(var.subnetwork_cidrs), count.index))}"
}

output "subnetwork_public_names" {
  value = ["${google_compute_subnetwork.subnetwork_public.*.name}"]
}

