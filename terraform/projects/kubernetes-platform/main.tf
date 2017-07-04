# == Manifest: projects::kubernetes-platform
#
# Create everything required to bring up a Kubernetes cluster in AWS.
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
# kubernetes_platform_key_name
# kubernetes_platform_public_key
# kubernetes_platform_bucket
#
# === Outputs:
#
# vpc_id
# public_subnet_ids
# security_group_ssh_access_id
# jumpbox_dns_name
# jumpbox_iam_role_id
# private_subnet_ids
# private_subnet_names_route_tables_map
# security_group_alb_ingress_controller_id
# security_group_alb_ingress_controller_name
# security_group_worker_ingress_controller_id
# kubernetes_ssh_key_name
# kubernetes_kms_key_arn
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

variable "remote_state_dns_zone_key" {
  type        = "string"
  description = "DNS zone TF remote state key"
}

variable "remote_state_dns_zone_bucket" {
  type        = "string"
  description = "DNS zone TF remote state bucket"
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

variable "kubernetes_platform_key_name" {
  type        = "string"
  description = "The name for the Kubernetes Application cluster key pair"
}

variable "kubernetes_platform_public_key" {
  type        = "string"
  description = "The Kubernetes platform cluster public key material"
}

variable "kubernetes_platform_bucket" {
  type        = "string"
  description = "The Kubernetes platform cluster bucket for kube-aws"
}

# Resources
# --------------------------------------------------------------
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

data "terraform_remote_state" "dns_zone" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_dns_zone_bucket}"
    key    = "${var.remote_state_dns_zone_key}"
    region = "${var.aws_region}"
  }
}

module "kubernetes_platform_public_subnet" {
  source                    = "../../modules/aws/network/public_subnet"
  name                      = "kubernetes_platform_public_subnet"
  vpc_id                    = "${data.terraform_remote_state.govuk_network_base.vpc_id}"
  route_table_public_id     = "${data.terraform_remote_state.govuk_network_base.route_table_public_id}"
  subnet_cidrs              = "${var.public_subnet_cidrs}"
  subnet_availability_zones = "${var.public_subnet_availability_zones}"
}

module "kubernetes_platform_jumpbox" {
  source                  = "../../modules/aws/network/jumpbox"
  name                    = "kubernetes-platform-jumpbox"
  vpc_id                  = "${data.terraform_remote_state.govuk_network_base.vpc_id}"
  trusted_ips             = "${var.office_ips}"
  elb_subnet_ids          = "${module.kubernetes_platform_public_subnet.subnet_ids}"
  jumpbox_subnet_ids      = "${module.kubernetes_platform_public_subnet.subnet_ids}"
  create_jumpbox_dns_name = true
  jumpbox_dns_name        = "${var.jumpbox_dns_name}"
  zone_id                 = "${data.terraform_remote_state.dns_zone.zone_id}"
  create_jumpbox_key      = true
  jumpbox_key_name        = "kubernetes-platform-jumpbox-key"
  jumpbox_public_key      = "${var.jumpbox_public_key}"
  jumpbox_ssh_keys        = "${var.jumpbox_ssh_keys}"
}

module "kubernetes_platform_nat" {
  source            = "../../modules/aws/network/nat"
  subnet_ids        = "${matchkeys(values(module.kubernetes_platform_public_subnet.subnet_names_ids_map), keys(module.kubernetes_platform_public_subnet.subnet_names_ids_map), var.public_subnet_nat_gateway_enable)}"
  subnet_ids_length = "${length(var.public_subnet_nat_gateway_enable)}"
}

# Compute subnet_nat_gateways
data "template_file" "nat_gateway_association_subnet_id" {
  count    = "${length(keys(var.private_subnet_nat_gateway_association))}"
  template = "$${subnet_id}"

  vars {
    subnet_id = "${lookup(module.kubernetes_platform_public_subnet.subnet_names_ids_map, element(values(var.private_subnet_nat_gateway_association), count.index))}"
  }
}

data "template_file" "nat_gateway_association_nat_id" {
  count    = "${length(keys(var.private_subnet_nat_gateway_association))}"
  template = "$${nat_gateway_id}"
  depends_on = ["data.template_file.nat_gateway_association_subnet_id"]

  vars {
    nat_gateway_id = "${lookup(module.kubernetes_platform_nat.nat_gateway_subnets_ids_map, element(data.template_file.nat_gateway_association_subnet_id.*.rendered, count.index))}"
  }
}

module "kubernetes_platform_private_subnet" {
  source                     = "../../modules/aws/network/private_subnet"
  name                       = "kubernetes_platform_private_subnet"
  vpc_id                     = "${data.terraform_remote_state.govuk_network_base.vpc_id}"
  subnet_cidrs               = "${var.private_subnet_cidrs}"
  subnet_availability_zones  = "${var.private_subnet_availability_zones}"
  subnet_nat_gateways        = "${zipmap(keys(var.private_subnet_nat_gateway_association), data.template_file.nat_gateway_association_nat_id.*.rendered)}"
  subnet_nat_gateways_length = "${length(keys(var.private_subnet_nat_gateway_association))}"
}

resource "aws_security_group" "kubernetes_platform_alb_ingress_controller" {
  name        = "kubernetes_platform_alb_ingress_controller"
  description = "Kubernetes Application ALB security group"
  vpc_id      = "${data.terraform_remote_state.govuk_network_base.vpc_id}"

  tags {
    Name = "kubernetes_platform_alb_ingress_controller"
  }
}

resource "aws_security_group_rule" "in_443" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.kubernetes_platform_alb_ingress_controller.id}"
}

resource "aws_security_group_rule" "out_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.kubernetes_platform_alb_ingress_controller.id}"
}

resource "aws_security_group" "kubernetes_platform_worker_ingress_controller" {
  name        = "kubernetes_platform_worker_ingress_controller"
  description = "Kubernetes Application worker ALB security group"
  vpc_id      = "${data.terraform_remote_state.govuk_network_base.vpc_id}"

  tags {
    Name = "kubernetes_platform_worker_ingress_controller"
  }
}

resource "aws_security_group_rule" "in_alb_ingress_controller" {
  type                     = "ingress"
  from_port                = 30000
  to_port                  = 32767
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.kubernetes_platform_alb_ingress_controller.id}"
  security_group_id        = "${aws_security_group.kubernetes_platform_worker_ingress_controller.id}"
}

resource "aws_security_group_rule" "out_worker_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.kubernetes_platform_worker_ingress_controller.id}"
}

resource "aws_key_pair" "kubernetes_platform_key" {
  key_name   = "${var.kubernetes_platform_key_name}"
  public_key = "${var.kubernetes_platform_public_key}"
}

resource "aws_kms_key" "kubernetes_platform_kms" {
  description = "KMS key for Kubernetes platform"

  tags {
    Name = "kubernetes_platform"
  }
}

resource "aws_s3_bucket" "kubernetes_platform_bucket" {
  bucket = "${var.kubernetes_platform_bucket}"
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
# --------------------------------------------------------------
output "vpc_id" {
  value       = "${data.terraform_remote_state.govuk_network_base.vpc_id}"
  description = "VPC ID where the stack resources are created"
}

output "public_subnet_ids" {
  value       = "${module.kubernetes_platform_public_subnet.subnet_ids}"
  description = "List of public subnet IDs"
}

output "security_group_ssh_access_id" {
  value       = "${module.kubernetes_platform_jumpbox.security_group_ssh_access_id}"
  description = "Security group ID to enable SSH access from the jumpbox to your private resources"
}

output "jumpbox_dns_name" {
  value       = "${module.kubernetes_platform_jumpbox.jumpbox_dns_name}"
  description = "DNS name to access the jumpbox"
}

output "jumpbox_iam_role_id" {
  value       = "${module.kubernetes_platform_jumpbox.jumpbox_iam_role_id}"
  description = "Jumpbox IAM Role ID. Use with aws_iam_role_policy resources to attach specific permissions to the jumpbox profile"
}

output "private_subnet_ids" {
  value       = "${module.kubernetes_platform_private_subnet.subnet_ids}"
  description = "List of private subnet IDs"
}

output "private_subnet_names_route_tables_map" {
  value       = "${module.kubernetes_platform_private_subnet.subnet_names_route_tables_map}"
  description = "Map containing the name of each private subnet and route_table ID associated"
}

output "security_group_alb_ingress_controller_id" {
  value       = "${aws_security_group.kubernetes_platform_alb_ingress_controller.id}"
  description = "Security group to enable access to ingress-controller ALBs. ID or name can be applied to Kubernetes Ingress resources"
}

output "security_group_alb_ingress_controller_name" {
  value       = "${aws_security_group.kubernetes_platform_alb_ingress_controller.name}"
  description = "Security group to enable access to ingress-controller ALBs. ID or name can be applied to Kubernetes Ingress resources"
}

output "security_group_worker_ingress_controller_id" {
  value       = "${aws_security_group.kubernetes_platform_worker_ingress_controller.id}"
  description = "Security group to enable access to Kubernetes services from ingress-controller ALBs. ID needs to be applied to Kubernetes worker nodes"
}

output "kubernetes_ssh_key_name" {
  value       = "${aws_key_pair.kubernetes_platform_key.key_name}"
  description = "Kubernetes SSH key name for kube-aws"
}

output "kubernetes_kms_key_arn" {
  value       = "${aws_kms_key.kubernetes_platform_kms.arn}"
  description = "Kubernetes KMS key arn for kube-aws"
}

output "kubernetes_alb_ingress_controller_policy_arn" {
  value       = "${aws_iam_policy.kubernetes_alb_ingress_controller.arn}"
  description = "Policy ARN to attach to the Kubernetes worker IAM profile to support ALB ingress controllers"
}
