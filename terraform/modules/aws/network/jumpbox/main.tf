# == Module: aws::network::jumpbox
#
# This module creates a jumpbox in a autoscaling group that expands
# in the subnets specified by the variable jumpbox_subnet_ids. An ELB
# is also provisioned to access the jumpbox. The jumpbox AMI is Ubuntu,
# you can specify the version with the jumpbox_ami_filter_name variable.
# The machine type can also be configured with a variable.
#
# The user SSH public keys to access the jumpbox should be added to the
# jumpbox_ssh_keys variable. If no keys are provided, only the default
# jumpbox_key_name will provide access.
#
# When the variable create_jumpbox_dns_name is set to true, this module
# will create a DNS name jumpbox_dns_name in the zone_id specified pointing
# to the ELB record.
#
# Additionally, this module will create a security group to add to private
# resources that we want to enable SSH from the jumpbox created, and a
# jumpbox IAM role that we can attach policies to in other modules.
#
# === Variables:
#
# name
# vpc_id
# trusted_ips
# elb_subnet_ids
# jumpbox_subnet_ids
# create_jumpbox_dns_name
# jumpbox_dns_name
# zone_id
# jumpbox_ami_filter_name
# jumpbox_instance_type
# create_jumpbox_key
# jumpbox_key_name
# jumpbox_public_key
# jumpbox_user_data_file
# jumpbox_ssh_user
# jumpbox_ssh_keys
# jumpbox_additional_user_data_script
#
# === Outputs:
#
# jumpbox_security_group_ssh_access_id
# jumpbox_dns_name
# jumpbox_iam_role_id
#

variable "name" {
  type        = "string"
  description = "Jumpbox resources name. Only alphanumeric characters and hyphens allowed"
}

variable "vpc_id" {
  type        = "string"
  description = "The ID of the VPC in which the jumpbox is created"
}

variable "trusted_ips" {
  type        = "list"
  description = "List of trusted IPs to enable access to the jumpbox"
}

variable "elb_subnet_ids" {
  type        = "list"
  description = "List of subnet ids where the jumpbox ELB can be deployed"
}

variable "jumpbox_subnet_ids" {
  type        = "list"
  description = "List of subnet ids where the jumpbox can be deployed"
}

variable "create_jumpbox_dns_name" {
  type        = "string"
  description = "Whether to add a DNS Alias to resolve the jumpbox ELB record"
  default     = false
}

variable "jumpbox_dns_name" {
  type        = "string"
  description = "Jumpbox DNS name, when jumpbox_dns_name_enable is true"
  default     = ""
}

variable "zone_id" {
  type        = "string"
  description = "Route53 Zone ID to add the jumpbox DNS record, when jumpbox_dns_name_enable is true"
  default     = ""
}

variable "jumpbox_ami_filter_name" {
  type        = "string"
  description = "Name to use to find AMI images for the jumpbox instance"
  default     = "ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"
}

variable "jumpbox_instance_type" {
  type        = "string"
  description = "Jumpbox instance type"
  default     = "t2.micro"
}

variable "create_jumpbox_key" {
  type        = "string"
  description = "Whether to create a key pair for the jumpbox launch configuration"
  default     = false
}

variable "jumpbox_key_name" {
  type        = "string"
  description = "Name of the jumpbox key"
}

variable "jumpbox_public_key" {
  type        = "string"
  description = "The jumpbox default public key material"
  default     = ""
}

variable "jumpbox_user_data_file" {
  type        = "string"
  description = "Name of template file containing the jumpbox user_data provisioning script"
  default     = "user_data.sh"
}

variable "jumpbox_ssh_user" {
  type        = "string"
  description = "Jumpbox SSH access username"
  default     = "ubuntu"
}

variable "jumpbox_ssh_keys" {
  type        = "list"
  description = "List of Jumpbox SSH access keys"
  default     = []
}

variable "jumpbox_additional_user_data_script" {
  type        = "string"
  description = "Append addition user-data script"
  default     = ""
}

# Resources
#--------------------------------------------------------------
resource "aws_security_group" "jumpbox_elb" {
  name        = "jumpbox_${var.name}_elb"
  vpc_id      = "${var.vpc_id}"
  description = "Bastion ELB security group (only SSH inbound access from trusted IPs is allowed)"

  tags {
    Name = "${var.name}"
  }
}

resource "aws_security_group_rule" "jumpbox_elb_in_22" {
  type              = "ingress"
  from_port         = "22"
  to_port           = "22"
  protocol          = "tcp"
  cidr_blocks       = "${var.trusted_ips}"
  security_group_id = "${aws_security_group.jumpbox_elb.id}"
}

resource "aws_security_group_rule" "jumpbox_elb_out_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.jumpbox_elb.id}"
}


resource "aws_security_group" "jumpbox" {
  name        = "jumpbox_${var.name}"
  vpc_id      = "${var.vpc_id}"
  description = "Bastion security group (only SSH inbound access from ELB SG is allowed)"

  tags {
    Name = "${var.name}"
  }
}

resource "aws_security_group_rule" "jumpbox_from_elb_in_22" {
  type                     = "ingress"
  from_port                = "22"
  to_port                  = "22"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.jumpbox_elb.id}"
  security_group_id        = "${aws_security_group.jumpbox.id}"
}

resource "aws_security_group_rule" "jumpbox_from_elb_out_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.jumpbox.id}"
}

resource "aws_security_group" "ssh_access" {
  name        = "${var.name}_ssh_access"
  vpc_id      = "${var.vpc_id}"
  description = "Global SSH access security group (only SSH inbound access from jumpbox SG is allowed)"

  tags {
    Name = "${var.name}"
  }
}

resource "aws_security_group_rule" "global_from_jumpbox_in_22" {
  type                     = "ingress"
  from_port                = "22"
  to_port                  = "22"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.jumpbox.id}"
  security_group_id        = "${aws_security_group.ssh_access.id}"
}

resource "aws_security_group_rule" "global_from_jumpbox_out_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.ssh_access.id}"
}

resource "aws_elb" "jumpbox" {
  name            = "${var.name}"
  subnets         = ["${var.elb_subnet_ids}"]
  security_groups = ["${aws_security_group.jumpbox_elb.id}"]

  listener {
    instance_port     = 22
    instance_protocol = "tcp"
    lb_port           = 22
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:22"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    Name = "${var.name}"
  }
}

resource "aws_route53_record" "jumpbox" {
  count   = "${var.create_jumpbox_dns_name}"
  zone_id = "${var.zone_id}"
  name    = "${var.jumpbox_dns_name}"
  type    = "A"

  alias {
    name                   = "${aws_elb.jumpbox.dns_name}"
    zone_id                = "${aws_elb.jumpbox.zone_id}"
    evaluate_target_health = true
  }
}

data "aws_ami" "jumpbox_ami_ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.jumpbox_ami_filter_name}"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

data "template_file" "jumpbox_user_data" {
  template = "${file("${path.module}/${var.jumpbox_user_data_file}")}"

  vars {
    ssh_user                    = "${var.jumpbox_ssh_user}"
    ssh_keys                    = "${join("\n", var.jumpbox_ssh_keys)}"
    additional_user_data_script = "${var.jumpbox_additional_user_data_script}"
  }
}

resource "aws_iam_role" "jumpbox" {
  name = "${var.name}"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "jumpbox" {
  name = "${var.name}"
  role = "${aws_iam_role.jumpbox.name}"
}

resource "aws_key_pair" "jumpbox_key" {
  count      = "${var.create_jumpbox_key}"
  key_name   = "${var.jumpbox_key_name}"
  public_key = "${var.jumpbox_public_key}"
}

resource "aws_launch_configuration" "jumpbox" {
  name_prefix   = "${var.name}-"
  image_id      = "${data.aws_ami.jumpbox_ami_ubuntu.id}"
  instance_type = "${var.jumpbox_instance_type}"
  user_data     = "${data.template_file.jumpbox_user_data.rendered}"

  security_groups = ["${aws_security_group.jumpbox.id}"]

  iam_instance_profile        = "${aws_iam_instance_profile.jumpbox.name}"
  associate_public_ip_address = false
  key_name                    = "${var.jumpbox_key_name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "jumpbox" {
  name = "${var.name}"

  vpc_zone_identifier = [
    "${var.jumpbox_subnet_ids}",
  ]

  desired_capacity          = "1"
  min_size                  = "1"
  max_size                  = "1"
  health_check_grace_period = "60"
  health_check_type         = "EC2"
  force_delete              = false
  wait_for_capacity_timeout = 0
  launch_configuration      = "${aws_launch_configuration.jumpbox.name}"
  load_balancers            = ["${aws_elb.jumpbox.name}"]

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  tag {
    key                 = "Name"
    value               = "${var.name}"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Outputs
#--------------------------------------------------------------
output "security_group_ssh_access_id" {
  value       = "${aws_security_group.ssh_access.id}"
  description = "Security group ID to enable SSH access from the jumpbox to your private resources"
}

output "jumpbox_dns_name" {
  value       = "${var.create_jumpbox_dns_name == 1 ? var.jumpbox_dns_name : aws_elb.jumpbox.dns_name}"
  description = "DNS name to access the jumpbox"
}

output "jumpbox_iam_role_id" {
  value       = "${aws_iam_role.jumpbox.id}"
  description = "Jumpbox IAM Role ID. Use with aws_iam_role_policy resources to attach specific permissions to the jumpbox profile"
}

