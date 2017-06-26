#--------------------------------------------------------------
# This module creates all resources necessary for a AWS VPC,
# IGW and IGW route table
#--------------------------------------------------------------

# Variables
#--------------------------------------------------------------
variable "name" {
  type        = "string"
  description = "A name tag for the VPC"
}

variable "cidr" {
  type        = "string"
  description = "The cidr block of the desired VPC"
}

# Resources
#--------------------------------------------------------------
resource "aws_vpc" "vpc" {
  cidr_block           = "${var.cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "${var.name}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_internet_gateway" "public" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.name}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.public.id}"
  }

  tags {
    Name = "${var.name}"
  }
}

# Outputs
#--------------------------------------------------------------
output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "vpc_cidr" {
  value = "${aws_vpc.vpc.cidr_block}"
}

output "internet_gateway_id" {
  value = "${aws_internet_gateway.public.id}"
}

output "route_table_public_id" {
  value = "${aws_route_table.public.id}"
}
