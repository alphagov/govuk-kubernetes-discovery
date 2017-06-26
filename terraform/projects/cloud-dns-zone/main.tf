# == Manifest: projects::cloud-dns-zone
#
# Create the main DNS zone that holds further DNS records related to the stack.
#
# === Variables:
#
# aws_region
# zone_name
# zone_dns_name
#
# === Outputs:
#
# zone_id
# name_servers
#
variable "aws_region" {
  type        = "string"
  description = "AWS region"
  default     = "eu-west-1"
}

variable "zone_name" {
  type        = "string"
  description = "A unique name for the DNS zone"
}

variable "zone_dns_name" {
  type        = "string"
  description = "Fully qualified DNS zone domain"
}

# Resources
#
terraform {
  backend "s3" {}
}

provider "aws" {
  region = "${var.aws_region}"
}

module "dns_zone" {
  source   = "../../modules/aws/route53_zone"
  name     = "${var.zone_name}"
  dns_name = "${var.zone_dns_name}"
}

# Outputs
#
output "zone_id" {
  value = "${module.dns_zone.zone_id}"
}

output "name_servers" {
  value = "${module.dns_zone.name_servers}"
}
