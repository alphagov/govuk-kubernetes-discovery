# == Manifest: projects::test-network
#
# This module tests the creation of full network stacks.
#
# === Variables:
#
# aws_region
# remote_state_govuk_network_base_key
# remote_state_govuk_network_base_bucket
# remote_state_dns_zone_key
# remote_state_dns_zone_bucket
# public_subnet_cidrs
# public_subnet_availability_zones
# jumpbox_dns_name
# jumpbox_public_key
# jumpbox_ssh_keys
# office_ips
# public_subnet_nat_gateway_enable
# private_subnet_cidrs
# private_subnet_availability_zones
# private_subnet_nat_gateway_association
#
# === Outputs:
#
# vpc_id
# public_subnet_ids
# public_subnet_names_ids_map
# security_group_ssh_access_id
# jumpbox_dns_name
# jumpbox_iam_role_id
# private_subnet_ids
# private_subnet_names_ids_map
# private_subnet_names_route_tables_map
#

variable "aws_region" {
  type        = "string"
  description = "AWS region"
  default     = "eu-west-1"
}

variable "remote_state_dns_zone_key" {
  type        = "string"
  description = "DNS zone TF remote state key"
}

variable "remote_state_dns_zone_bucket" {
  type        = "string"
  description = "DNS zone TF remote state bucket"
}

variable "vpc_name" {
  type        = "string"
  description = "A name tag for the VPC"
}

variable "vpc_cidr" {
  type        = "string"
  description = "VPC IP address range, represented as a CIDR block"
}

variable "public_subnet_cidrs" {
  type        = "map"
  description = "Map containing public subnet names and CIDR associated"
}

variable "public_subnet_availability_zones" {
  type        = "map"
  description = "Map containing public subnet names and availability zones associated"
}

variable "jumpbox_dns_name" {
  type        = "string"
  description = "DNS name of the jumpbox"
}

variable "jumpbox_public_key" {
  type        = "string"
  description = "The jumpbox public key material"
}

variable "jumpbox_ssh_keys" {
  type        = "list"
  description = "List of users public key material to enable access to the jumpbox"
}

variable "office_ips" {
  type        = "list"
  description = "GDS office IPs"
}

variable "public_subnet_nat_gateway_enable" {
  type        = "list"
  description = "List of public subnet names where we want to create a NAT Gateway"
}

variable "private_subnet_cidrs" {
  type        = "map"
  description = "Map containing private subnet names and CIDR associated"
}

variable "private_subnet_availability_zones" {
  type        = "map"
  description = "Map containing private subnet names and availability zones associated"
}

variable "private_subnet_nat_gateway_association" {
  type        = "map"
  description = "Map of private subnet names and public subnet used to route external traffic (the public subnet must be listed in public_subnet_nat_gateway_enable to ensure it has a NAT gateway attached)"
}

# Resources
# --------------------------------------------------------------
terraform {
  backend "s3" {}
}

provider "aws" {
  region = "${var.aws_region}"
}

module "test_vpc" {
  source = "../../modules/aws/network/vpc"
  name   = "${var.vpc_name}"
  cidr   = "${var.vpc_cidr}"
}

data "terraform_remote_state" "dns_zone" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_dns_zone_bucket}"
    key    = "${var.remote_state_dns_zone_key}"
    region = "eu-west-1"
  }
}

module "test_public_subnet" {
  source                    = "../../modules/aws/network/public_subnet"
  name                      = "test_public_subnet"
  vpc_id                    = "${module.test_vpc.vpc_id}"
  route_table_public_id     = "${module.test_vpc.route_table_public_id}"
  subnet_cidrs              = "${var.public_subnet_cidrs}"
  subnet_availability_zones = "${var.public_subnet_availability_zones}"
}

module "test_jumpbox" {
  source                  = "../../modules/aws/network/jumpbox"
  name                    = "test-jumpbox"
  vpc_id                  = "${module.test_vpc.vpc_id}"
  trusted_ips             = "${var.office_ips}"
  elb_subnet_ids          = "${module.test_public_subnet.subnet_ids}"
  jumpbox_subnet_ids      = "${module.test_public_subnet.subnet_ids}"
  create_jumpbox_dns_name = true
  jumpbox_dns_name        = "${var.jumpbox_dns_name}"
  zone_id                 = "${data.terraform_remote_state.dns_zone.zone_id}"
  create_jumpbox_key      = true
  jumpbox_key_name        = "test-jumpbox-key"
  jumpbox_public_key      = "${var.jumpbox_public_key}"
  jumpbox_ssh_keys        = "${var.jumpbox_ssh_keys}"
}

module "test_nat" {
  source     = "../../modules/aws/network/nat"
  subnet_ids = "${matchkeys(values(module.test_public_subnet.subnet_names_ids_map), keys(module.test_public_subnet.subnet_names_ids_map), var.public_subnet_nat_gateway_enable)}"
  subnet_ids_length = "${length(var.public_subnet_nat_gateway_enable)}"
}

# Intermediate variables in Terraform are not supported.
# There are a few workarounds to get around this limitation,
# https://github.com/hashicorp/terraform/issues/4084
# The template_file resources allow us to use a private_subnet_nat_gateway_association
# variable to select which NAT gateway, if any, each private
# subnet must use to route public traffic.
data "template_file" "nat_gateway_association_subnet_id" {
  count    = "${length(keys(var.private_subnet_nat_gateway_association))}"
  template = "$${subnet_id}"

  vars {
    subnet_id = "${lookup(module.test_public_subnet.subnet_names_ids_map, element(values(var.private_subnet_nat_gateway_association), count.index))}"
  }
}

data "template_file" "nat_gateway_association_nat_id" {
  count    = "${length(keys(var.private_subnet_nat_gateway_association))}"
  template = "$${nat_gateway_id}"
  depends_on = ["data.template_file.nat_gateway_association_subnet_id"]

  vars {
    nat_gateway_id = "${lookup(module.test_nat.nat_gateway_subnets_ids_map, element(data.template_file.nat_gateway_association_subnet_id.*.rendered, count.index))}"
  }
}

module "test_private_subnet" {
  source                     = "../../modules/aws/network/private_subnet"
  name                       = "test_private_subnet"
  vpc_id                     = "${module.test_vpc.vpc_id}"
  subnet_cidrs               = "${var.private_subnet_cidrs}"
  subnet_availability_zones  = "${var.private_subnet_availability_zones}"
  subnet_nat_gateways        = "${zipmap(keys(var.private_subnet_nat_gateway_association), data.template_file.nat_gateway_association_nat_id.*.rendered)}"
  subnet_nat_gateways_length = "${length(keys(var.private_subnet_nat_gateway_association))}"
}

# Outputs
# --------------------------------------------------------------
output "vpc_id" {
  value       = "${module.test_vpc.vpc_id}"
  description = "VPC ID where the stack resources are created"
}

output "public_subnet_ids" {
  value       = "${module.test_public_subnet.subnet_ids}"
  description = "List of public subnet IDs"
}

output "public_subnet_names_ids_map" {
  value       = "${module.test_public_subnet.subnet_names_ids_map}"
  description = "Map containing the pair name-id for each public subnet created"
}

output "security_group_ssh_access_id" {
  value       = "${module.test_jumpbox.security_group_ssh_access_id}"
  description = "Security group ID to enable SSH access from the jumpbox to your private resources"
}

output "jumpbox_dns_name" {
  value       = "${module.test_jumpbox.jumpbox_dns_name}"
  description = "DNS name to access the jumpbox"
}

output "jumpbox_iam_role_id" {
  value       = "${module.test_jumpbox.jumpbox_iam_role_id}"
  description = "Jumpbox IAM Role ID. Use with aws_iam_role_policy resources to attach specific permissions to the jumpbox profile"
}

output "private_subnet_ids" {
  value       = "${module.test_private_subnet.subnet_ids}"
  description = "List of private subnet IDs"
}

output "private_subnet_names_ids_map" {
  value       = "${module.test_private_subnet.subnet_names_ids_map}"
  description = "Map containing the pair name-id for each private subnet created"
}

output "private_subnet_names_route_tables_map" {
  value       = "${module.test_private_subnet.subnet_names_route_tables_map}"
  description = "Map containing the name of each private subnet and route_table ID associated"
}
