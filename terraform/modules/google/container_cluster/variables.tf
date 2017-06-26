variable "zone" {
  type        = "string"
  description = "The zone that the master and the number of nodes specified in initial_node_count should be created in"
}

variable "additional_zones" {
  type        = "list"
  description = "Additional zones to place worker nodes in."
}

variable "initial_node_count" {
  type        = "string"
  description = "The number of nodes to create per zone (and additional zone)."
}

variable "name" {
  type        = "string"
  description = "The name of the cluster, unique within the project and zone"
}

variable "network" {
  type        = "string"
  description = "The name or self_link of the Google Compute Engine network to which the cluster is connected"
}

variable "subnetwork" {
  type        = "string"
  description = "The name of the Google Compute Engine subnetwork in which the cluster's instances are launched"
}

variable "master_username" {
  type        = "string"
  description = "The username to use for HTTP basic authentication when accessing the Kubernetes master endpoint"
}

variable "master_password" {
  type        = "string"
  description = "The password to use for HTTP basic authentication when accessing the Kubernetes master endpoint"
}

variable "version" {
  type        = "string"
  description = "Kubernetes cluster version"
}

