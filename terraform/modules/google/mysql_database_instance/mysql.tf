#
# As per the terraform docs (https://www.terraform.io/docs/providers/google/r/sql_database_instance.html)
# this instance will have its "root%" account deleted.
#

resource "google_sql_database_instance" "mysql_instance" {
  name             = "${var.name}"
  region           = "${var.region}"
  database_version = "MYSQL_${var.mysql_version}"

  settings {
    tier            = "${var.tier}"
    disk_size       = "${var.disk_size}"
    disk_autoresize = true
    # FIXME we probably want to change this to PD_SSD once we're out of testing
    disk_type       = "PD_HDD"
  }
}

# Create a user
resource "google_sql_user" "mysql_proxy_user" {
  name     = "${var.username}"
  host     = "%"
  instance = "${google_sql_database_instance.mysql_instance.name}"
  password = "${var.password}"
}
