variable "name" {
  type = "string"
  default = "mysql-instance"
}

variable "region" {
  type = "string"
  description = "The region (not a specific zone) to place the database in."
}

variable "mysql_version" {
  type = "string"
  description = "Which version of MySQL to use ('5_6' or '5_7' are valid)."
}

variable "tier" {
  type = "string"
  description = "Instance size to use."
}

variable "disk_size" {
  type = "string"
  description = "Size (in GB) of the hard disk to provision."
}

variable "username" {
  type = "string"
  description = "User to create on the database (root is disabled)."
}

variable "password" {
  type = "string"
  description = "Password for accessing the database."
}
