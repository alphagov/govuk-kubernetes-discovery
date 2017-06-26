# == Module: aws::dns_zone
#
# Creates a DNS zone in Amazon Route53.
#
# === Variables:
#
# name
# dns_name
#
# === Outputs:
#
# zone_id
# name_servers
#
variable "name" {
  type        = "string"
  description = "Name of the resource tag"
}

variable "dns_name" {
  type        = "string"
  description = "DNS name to create"
}

resource "aws_route53_zone" "dns_zone" {
  name = "${var.dns_name}"

  tags {
    Name = "${var.name}"
  }
}

output "zone_id" {
  value       = "${aws_route53_zone.dns_zone.zone_id}"
  description = "ID of the DNS zone that is created"
}

output "name_servers" {
  value       = "${aws_route53_zone.dns_zone.name_servers}"
  description = "The nameservers that are serving the created DNS zone"
}
