variable "google_project" {
  type        = "string"
  description = "Project ID"
}

variable "google_region" {
  type        = "string"
  description = "Google region"
  default     = "europe-west1"
}

variable "network_name" {
  type        = "string"
  description = "A unique name for the network"
}

variable "network_cidr" {
  type        = "string"
  description = "(NOT IN USE) Network IP address range, represented as a CIDR block. Only used to enable internal traffic in the firewall."
}

variable "public_subnetworks_cidrs" {
  type        = "map"
  description = "Map containing public subnet names and CIDR associated"
}

variable "public_subnetworks_regions" {
  type        = "map"
  description = "Map containing public subnet names and region associated"
}

variable "office_ips" {
  type        = "list"
  description = "GDS office IPs"
}
