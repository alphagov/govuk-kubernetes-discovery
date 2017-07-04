
"public_subnet_cidrs" = {
  "kubernetes_platform_public_a" = "10.0.7.0/24"
  "kubernetes_platform_public_b" = "10.0.8.0/24"
  "kubernetes_platform_public_c" = "10.0.9.0/24"
}

"public_subnet_availability_zones" = {
  "kubernetes_platform_public_a" = "eu-west-1a"
  "kubernetes_platform_public_b" = "eu-west-1b"
  "kubernetes_platform_public_c" = "eu-west-1c"
}

"private_subnet_cidrs" = {
  "kubernetes_platform_private_a" = "10.0.13.0/24"
  "kubernetes_platform_private_b" = "10.0.14.0/24"
  "kubernetes_platform_private_c" = "10.0.15.0/24"
}

"private_subnet_availability_zones" = {
  "kubernetes_platform_private_a" = "eu-west-1a"
  "kubernetes_platform_private_b" = "eu-west-1b"
  "kubernetes_platform_private_c" = "eu-west-1c"
}

"public_subnet_nat_gateway_enable" = [ "kubernetes_platform_public_a", "kubernetes_platform_public_b", "kubernetes_platform_public_c" ]

"private_subnet_nat_gateway_association" = {
  "kubernetes_platform_private_a" = "kubernetes_platform_public_a"
  "kubernetes_platform_private_b" = "kubernetes_platform_public_b"
  "kubernetes_platform_private_c" = "kubernetes_platform_public_c"
}

"kubernetes_platform_key_name" = "kubernetes-platform"
"kubernetes_platform_public_key" = "ssh-rsa deadbeefaC1yc2EAAAADAQABAAACAQC2TocJW+coJg/48EKToHKaV2my22GSfATKmHb4dsF2mqky+CezrzgEwGGXVeoveCI5fvBLVXvv0in9zMCduq1Aw1cWHVp5X0CwEPpB5Bx5Fg9c3KjMvnA0kInyNkf2eLCmhFKsv8f6XnnDkRTqHoZnT4yl3RvMWyC5SIiyqIsptjwuzrcAMRqMdFW58IrHZDxLC4XWBtRMALkpCsPdrIceYj6VEfi0Xo4AW4KO7qNZqG6u65+19rGRPoEamOaS5URwiaxef/XWCKpgV0yXmz5GdYJJmxJ70QYVMSSaUZx4i30LG4Ve/v42q1UfgybotjwPKClBxRx/jck3lgdQbPhhEhkyMJ7tpbAY8lFZKojhC2pYEJMO2h1+1JMcesTaLou+M7/HODFKZaIF98u6Iw6IW8MzJA/gjD1CtdbaPAvu3jDydUbBeodPUkclU0q1MfkKAmTsTLrMVEvXBywrqpXMZZDGa+2KsQAuTrOLEOTvyKSxynzS9+RXtX2+m3rGMP8SOAT/Yo/RuKnQp+rNnVQ6/fePHcV5ehC6V1IRv8VoGIa7qpPCOpttmzC3JsXrgthSEMl4soVEu1jxD6Sh28XVRZ5K1Z5FkhA81/XI1bh8ubnqMMm2p0T89sjPao2HkFyTTXYlX3Gpk1XRmYoaDsMmFsu/AMv3yFJR9d1JylmOxQ=="
"kubernetes_platform_bucket" = "kubernetes-platform-integration"

"remote_state_dns_zone_key" = "terraform-cloud-dns-zone.tfstate"
"remote_state_dns_zone_bucket" = "govuk-terraform-state-integration"
"remote_state_govuk_network_base_key" = "terraform-govuk-network-base.tfstate"
"remote_state_govuk_network_base_bucket" = "govuk-terraform-state-integration"

"jumpbox_dns_name" = "jumpboxplatform.integration.cloud.publishing.service.gov.uk."
"jumpbox_public_key" = "ssh-rsa DEADBEEFaC1yc2EAAAADAQABAAACAQC2TocJW+coJg/wEPpB5Bx5Fg9cKTuq1Aw1cWHVp5X0CNkf2eLCmhFoHKaV23KjMvnA0kIny48Emy22GSfATKmHb4KsdsF2mqky+CezrzgEwGGXVeoveCI5fvBLVXvv0in9zMCdv8f6XnnDkRTqHoZnT4yl3RvMWyC5SIiyqIsptjwuzrcAMRqMdFW58IrHZDxLC4XWBtRMALkpCsPdrIceYj6VEfi0Xo4AW4KO7qNZqG6u65+19rGRPoEamOaS5URwiaxef/XWCKpgV0yXmz5GdYJJmxJ70QYVMSSaUZx4i30LG4Ve/v42q1UfgybotjwPKClBxRx/jck3lgdQbPhhEhkyMJ7tpbAY8lFZKojhC2pYEJMO2h1+1JMcesTaLou+M7/HODFKZaIF98u6Iw6IW8MzJA/gjD1CtdbaPAvu3jDydUbBeodPUkclU0q1MfkKAmTsTLrMVEvXBywrqpXMZZDGa+2KsQAuTrOLEOTvyKSxynzS9+RXtX2+m3rGMP8SOAT/Yo/RuKnQp+rNnVQ6/fePHcV5ehC6V1IRv8VoGIa7qpPCOpttmzC3JsXrgthSEMl4soVEu1jxD6Sh28XVRZ5K1Z5FkhA81/XI1bh8ubnqMMm2p0T89sjPao2HkFyTTXYlX3Gpk1XRmYoaDsMmFsu/AMv3yFJR9d1JylmOxQ=="

"jumpbox_ssh_keys" = [
  "ssh-rsa deadbeefaC1yc2EAAAADAQABAAACAQCrUPBD4QsC+ynWuAUiiHr25IZsemZdVkdUWFLsy7PyEzgtPgjeS6wD86Vam+tDsKPSckmi9oi6JFW4z+rj3JLgFwqNO5YXlNBw56ePkICA2d8EszO3LxutyQrLrgB7WI1QT95ob5+JNSb1G3iFwDf5c12/qYuCI4xMkXu1xmLfdIKnpSjxbp7fS6O7zqGR4CiSsfvrWveGAbN27mSFdRJ2V22SKlA4Onhwj4YW5C60juWBqwnMEvBwfuOW/jc5JR+q2Ahyk+Yd1RrxLhJv0ydoKFuJopSg/x4yQUconi2cl53hKmfvcrYk5aYH+bI1rxUGegfOHF2L8JU9Y8RhHgC2OaAbhw4iR6gE1aSvb4MxA7W8UBykbP09sPoEhTzaHMLkRe/FvkudHvtNjHRR/PzD6UefMjoXx5MG970h55HT4iHmRCF/jBbqvkcm8cuU1S8JA7tNdufBRoNQ2qjTHwNJXZjE5Og0kgZzFq8viUPoM9dNn4tTRNds3uOmyQhQXMwYVwTL7XH+VHfIRcNbghojHjjB/wzKTZBXuP23V8hof+Nt+q0D5ZD3/yN2o9KLQpNIbieOuGsbhJRA3P8tm10GWEsyT08gc4ufeUm+3zmuhK0UmzYtsW5duLV34G3bPTMHONwqwO3715go3TXptADwQZNcSOcCDGAvVu7CYXAtlw== bob",
]

