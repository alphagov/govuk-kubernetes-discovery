variable "name" {
  type        = "string"
  description = "Name of the database to create"
  default     = "mysql-instance"
}

variable "mysql_version" {
  type        = "string"
  description = "Which version of MySQL to use (eg 5.5.46)"
}

variable "username" {
  type        = "string"
  description = "User to create on the database"
}

variable "password" {
  type        = "string"
  description = "Password for accessing the database."
}

variable "allocated_storage" {
  type        = "string"
  description = "The allocated storage in gigabytes."
  default     = "10"
}

variable "instance_class" {
  type        = "string"
  description = "The instance type of the RDS instance."
  default     = "db.t1.micro"
}

variable "db_subnet_ids" {
  type        = "list"
  description = "An array of VPC subnet IPs that the instance is created into."
}
