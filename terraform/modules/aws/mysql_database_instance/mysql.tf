resource "aws_db_subnet_group" "mysql_subnet_group" {
  name       = "${var.name}"
  subnet_ids = ["${var.db_subnet_ids}"]

  tags {
    Name = "${var.name}_db_subnet_group"
  }
}

resource "aws_db_instance" "mysql_instance" {
  name                 = "${var.name}"
  engine               = "mysql"
  engine_version       = "${var.mysql_version}"
  username             = "${var.username}"
  password             = "${var.password}"
  allocated_storage    = "${var.allocated_storage}"
  instance_class       = "${var.instance_class}"
  db_subnet_group_name = "${aws_db_subnet_group.mysql_subnet_group.name}"
}

output "rds_instance_id" {
  value = "${aws_db_instance.mysql_instance.id}"
}

output "address" {
  value = "${aws_db_instance.mysql_instance.address}"
}
