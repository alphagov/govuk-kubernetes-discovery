# == Manifest: projects::govuk-kubernetes-application
#
# Create everything required to bring up a Kubernetes cluster in AWS.
#
# === Variables:
#
# aws_region
# remote_state_govuk_network_base_key
# remote_state_govuk_network_base_bucket
# public_subnet_cidrs
# public_subnet_availability_zones
# office_ips
# kubernetes_application_key_name
# kubernetes_application_public_key
# kubernetes_application_bucket
#
# === Outputs:
#
# vpc_id
# public_subnets
# security_group_alb_ingress_controller_id
# security_group_alb_ingress_controller_name
# security_group_alb_worker_controller_id
# ssh_key_name
# kms_key_arn
# kubernetes_alb_ingress_controller_policy_arn
#
variable "aws_region" {
  type        = "string"
  description = "AWS region"
  default     = "eu-west-1"
}

variable "remote_state_govuk_network_base_key" {
  type        = "string"
  description = "Network base remote state key"
}

variable "remote_state_govuk_network_base_bucket" {
  type        = "string"
  description = "Network base remote state bucket"
}

variable "public_subnet_cidrs" {
  type        = "map"
  description = "Map containing public subnet names and CIDR associated"
}

variable "public_subnet_availability_zones" {
  type        = "map"
  description = "Map containing public subnet names and availability zones associated"
}

variable "office_ips" {
  type        = "list"
  description = "GDS office IPs"
}

variable "kubernetes_application_key_name" {
  type        = "string"
  description = "The name for the Kubernetes Application cluster key pair"
}

variable "kubernetes_application_public_key" {
  type        = "string"
  description = "The Coreos Kubernetes application cluster public key material"
}

variable "kubernetes_application_bucket" {
  type        = "string"
  description = "The Coreos Kubernetes application cluster bucket for kube-aws"
}

# Resources
#
terraform {
  backend "s3" {}
}

provider "aws" {
  region = "${var.aws_region}"
}

data "terraform_remote_state" "govuk_network_base" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_govuk_network_base_bucket}"
    key    = "${var.remote_state_govuk_network_base_key}"
    region = "${var.aws_region}"
  }
}

module "kubernetes_application_public_subnet" {
  source                    = "../../modules/aws/network/public_subnet"
  name                      = "kubernetes_application_public_subnet"
  vpc_id                    = "${data.terraform_remote_state.govuk_network_base.vpc_id}"
  route_table_public_id     = "${data.terraform_remote_state.govuk_network_base.route_table_public_id}"
  subnet_cidrs              = "${var.public_subnet_cidrs}"
  subnet_availability_zones = "${var.public_subnet_availability_zones}"
}

resource "aws_security_group" "kubernetes_application_alb_ingress_controller" {
  name        = "kubernetes_application_alb_ingress_controller"
  description = "Kubernetes Application ALB security group"
  vpc_id      = "${data.terraform_remote_state.govuk_network_base.vpc_id}"

  tags {
    Name = "kubernetes_application_alb_ingress_controller"
  }
}

resource "aws_security_group_rule" "in_443" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.kubernetes_application_alb_ingress_controller.id}"
}

resource "aws_security_group_rule" "out_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.kubernetes_application_alb_ingress_controller.id}"
}

resource "aws_security_group" "kubernetes_application_worker_ingress_controller" {
  name        = "kubernetes_application_worker_ingress_controller"
  description = "Kubernetes Application worker ALB security group"
  vpc_id      = "${data.terraform_remote_state.govuk_network_base.vpc_id}"

  tags {
    Name = "kubernetes_application_worker_ingress_controller"
  }
}

resource "aws_security_group_rule" "in_alb_ingress_controller" {
  type                     = "ingress"
  from_port                = 30000
  to_port                  = 32767
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.kubernetes_application_alb_ingress_controller.id}"
  security_group_id        = "${aws_security_group.kubernetes_application_worker_ingress_controller.id}"
}

resource "aws_security_group_rule" "out_worker_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.kubernetes_application_worker_ingress_controller.id}"
}

resource "aws_key_pair" "kubernetes_application_key" {
  key_name   = "${var.kubernetes_application_key_name}"
  public_key = "${var.kubernetes_application_public_key}"
}

resource "aws_kms_key" "kubernetes_application_kms" {
  description = "KMS key for Kubernetes application"

  tags {
    Name = "kubernetes_application"
  }
}

resource "aws_s3_bucket" "kubernetes_application_bucket" {
  bucket = "${var.kubernetes_application_bucket}"
  acl    = "private"
  region = "${var.aws_region}"
}

resource "aws_iam_policy" "kubernetes_alb_ingress_controller" {
  name        = "kubernetes_alb_ingress_controller"
  path        = "/"
  description = "Kubernetes ALB ingress controller policy"
  policy      = "${file("${path.module}/kubernetes_alb_ingress_controller_policy.json")}"
}

# Outputs
#
output "vpc_id" {
  value = "${data.terraform_remote_state.govuk_network_base.vpc_id}"
}

output "public_subnets" {
  value = "${module.kubernetes_application_public_subnet.subnet_ids}"
}

output "security_group_alb_ingress_controller_id" {
  value       = "${aws_security_group.kubernetes_application_alb_ingress_controller.id}"
  description = "Security group to enable access to ingress-controller ALBs. ID or name can be applied to Kubernetes Ingress resources"
}

output "security_group_alb_ingress_controller_name" {
  value       = "${aws_security_group.kubernetes_application_alb_ingress_controller.name}"
  description = "Security group to enable access to ingress-controller ALBs. ID or name can be applied to Kubernetes Ingress resources"
}

output "security_group_worker_ingress_controller_id" {
  value       = "${aws_security_group.kubernetes_application_worker_ingress_controller.id}"
  description = "Security group to enable access to Kubernetes services from ingress-controller ALBs. ID needs to be applied to Kubernetes worker nodes"
}

output "ssh_key_name" {
  value = "${aws_key_pair.kubernetes_application_key.key_name}"
}

output "kms_key_arn" {
  value = "${aws_kms_key.kubernetes_application_kms.arn}"
}

output "kubernetes_alb_ingress_controller_policy_arn" {
  value = "${aws_iam_policy.kubernetes_alb_ingress_controller.arn}"
}
