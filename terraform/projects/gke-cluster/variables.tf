variable "google_project" {
  type        = "string"
  description = "Project ID"
}

variable "google_region" {
  type        = "string"
  description = "Google region"
  default     = "europe-west1"
}

variable "cluster_name" {
  type        = "string"
  description = "The name of the Google container cluster, unique within the project and zone"
}

variable "cluster_zone" {
  type        = "string"
  description = "The zone that the master and the number of nodes specified in initial_node_count should be created in"
  default     = "europe-west1-b"
}

variable "cluster_network" {
  type        = "string"
  description = "The name of the Google Compute Engine network to which the cluster is connected"
}

variable "cluster_subnetwork" {
  type        = "string"
  description = "The name of the Google Compute Engine subnetwork in which the cluster's instances are launched"
}

variable "master_username" {
  type        = "string"
  description = "The username to use for HTTP basic authentication when accessing the Kubernetes master endpoint"
}

variable "additional_zones" {
  type        = "list"
  description = "Any additional zones to bring up cluster nodes in."
  default = [
    "europe-west1-c",
    "europe-west1-d",
  ]
}

variable "initial_node_count" {
  type        = "string"
  description = "The number of worker nodes to provision per zone."
  default     = "1"
}

variable "cluster_version" {
  type        = "string"
  description = "Kubernetes cluster version"
}

variable "zone_name" {
  type        = "string"
  description = "DNS zone name"
}

variable "frontend_dns_name" {
  type        = "string"
  description = "Frontend DNS name"
}

variable "backend_dns_name" {
  type        = "string"
  description = "Backend DNS name"
}
