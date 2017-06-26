# == Manifest: projects::release
#
# Create a public subnet and RDS instance for the Release application.
#
# === Variables:
#
# aws_region
# database_name
# database_username
# database_password
# database_dns_name
# remote_state_dns_zone_key
# remote_state_dns_zone_bucket
# remote_state_govuk_network_base_key
# remote_state_govuk_network_base_bucket
# public_subnet_cidrs
# public_subnet_availability_zones
#
# === Outputs:
#
# release_rds_instance_id
# release_rds_instance_address
#
variable "aws_region" {
  type        = "string"
  description = "AWS region"
  default     = "eu-west-1"
}

variable "database_name" {
  type        = "string"
  description = "The name of the database instance, it needs to be unique"
}

variable "database_username" {
  type        = "string"
  description = "The username to connect with the database instance"
}

variable "database_password" {
  type        = "string"
  description = "The password to connect with the database instance"
}

variable "database_dns_name" {
  type        = "string"
  description = "The DNS name to point to the RDS instance"
}

variable "remote_state_dns_zone_key" {
  type        = "string"
  description = "DNS zone TF remote state key"
}

variable "remote_state_dns_zone_bucket" {
  type        = "string"
  description = "DNS zone TF remote state bucket"
}

variable "remote_state_govuk_network_base_key" {
  type        = "string"
  description = "Network base TF remote state key"
}

variable "remote_state_govuk_network_base_bucket" {
  type        = "string"
  description = "Network base TF remote state bucket"
}

variable "public_subnet_cidrs" {
  type        = "map"
  description = "Subnets for components of the Release app"
}

variable "public_subnet_availability_zones" {
  type        = "map"
  description = "Availability zones for the subnets"
}

# Resources
#
terraform {
  backend "s3" {}
}

provider "aws" {
  region = "${var.aws_region}"
}

data "terraform_remote_state" "dns_zone" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_dns_zone_bucket}"
    key    = "${var.remote_state_dns_zone_key}"
    region = "${var.aws_region}"
  }
}

data "terraform_remote_state" "govuk_network_base" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_govuk_network_base_bucket}"
    key    = "${var.remote_state_govuk_network_base_key}"
    region = "${var.aws_region}"
  }
}

module "release_subnet" {
  source                    = "../../modules/aws/network/public_subnet"
  name                      = "release_subnet"
  vpc_id                    = "${data.terraform_remote_state.govuk_network_base.vpc_id}"
  route_table_public_id     = "${data.terraform_remote_state.govuk_network_base.route_table_public_id}"
  subnet_cidrs              = "${var.public_subnet_cidrs}"
  subnet_availability_zones = "${var.public_subnet_availability_zones}"
}

module "release_mysql" {
  source            = "../../modules/aws/mysql_database_instance"
  name              = "${var.database_name}"
  username          = "${var.database_username}"
  password          = "${var.database_password}"
  allocated_storage = "10"
  mysql_version     = "5.6.21"
  db_subnet_ids     = ["${module.release_subnet.subnet_ids}"]
}

resource "aws_route53_record" "release_db_dns_record" {
  zone_id = "${data.terraform_remote_state.dns_zone.zone_id}"
  name    = "${var.database_dns_name}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${module.release_mysql.address}"]
}

# Outputs
#
output "release_rds_instance_id" {
  value = "${module.release_mysql.rds_instance_id}"
}

output "release_rds_instance_address" {
  value = "${module.release_mysql.address}"
}
