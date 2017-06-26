"aws_region" = "eu-west-2"

"vpc_name" = "test-network"
"vpc_cidr" = "10.1.0.0/16"

"public_subnet_cidrs" = {
  "test_public_a" = "10.1.1.0/24"
  "test_public_b" = "10.1.2.0/24"
}

"public_subnet_availability_zones" = {
  "test_public_a" = "eu-west-2a"
  "test_public_b" = "eu-west-2b"
}

"private_subnet_cidrs" = {
  "test_private_a" = "10.1.4.0/24"
  "test_private_b" = "10.1.5.0/24"
}

"private_subnet_availability_zones" = {
  "test_private_a" = "eu-west-2a"
  "test_private_b" = "eu-west-2b"
}

"public_subnet_nat_gateway_enable" = [ "test_public_a" ]

"private_subnet_nat_gateway_association" = {
  "test_private_a" = "test_public_a"
  "test_private_b" = "test_public_a"
}

"office_ips" = ["160.124.11.90/32", "160.144.42.100/32", "160.139.69.244/32"]

"remote_state_dns_zone_key" = "terraform-cloud-dns-zone.tfstate"
"remote_state_dns_zone_bucket" = "govuk-terraform-state-integration"

"jumpbox_dns_name" = "testjumpbox.cloud.example.com."

"jumpbox_public_key" = "ssh-rsa deadbeefdeadbeefjMvnA0kIV2my22GSfA4pB5Bx5Fg98TKmHb4uq1AnyEKToHKaw1cWHVp5X0CNkf2eLCmhFKsdsF2mqky+CezrzgEwGGXVeoveCI5fvBLVXvv0inEAAAADAQABAAACAQC2TocJW+coJg/wE9zMCdv8f6XnnDkRTqHoZnT4yl3RvMWyC5SIiyqIsptjwuzrcAMRqMdFW58IrHZDxLC4XWBtRMALkpCsPdrIceYj6VEfi0Xo4AW4KO7qNZqG6u65+19rGRPoEamOaS5URwiaxef/XWCKpgV0yXmz5GdYJJmxJ70QYVMSSaUZx4i30LG4Ve/v42q1UfgybotjwPKClBxRx/jck3lgdQbPhhEhkyMJ7tpbAY8lFZKojhC2pYEJMO2h1+1JMcesTaLou+M7/HODFKZaIF98u6Iw6IW8MzJA/gjD1CtdbaPAvu3jDydUbBeodPUkclU0q1MfkKAmTsTLrMVEvXBywrqpXMZZDGa+2KsQAuTrOLEOTvyKSxynzS9+RXtX2+m3rGMP8SOAT/Yo/RuKnQp+rNnVQ6/fePHcV5ehC6V1IRv8VoGIa7qpPCOpttmzC3JsXrgthSEMl4soVEu1jxD6Sh28XVRZ5K1Z5FkhA81/XI1bh8ubnqMMm2p0T89sjPao2HkFyTTXYlX3Gpk1XRmYoaDsMmFsu/AMv3yFJR9d1JylmOxQ=="

"jumpbox_ssh_keys" = [
  "ssh-rsa DEADBEEF+dUWFLsy7PyEzgtPgjeSLgFwqNO5YXtDsFW4ZdVki6Jz+ynWuAUiiHr25lNKPSckmi9oIZsemBw56ePkICA2d8EszO3LxutyQrLrgB7WI1QT95ob5rj3JQsC++JNSb1G3iFwDf5c12/qYuCI4xMkXu1xmLfdIKnpSjxbp7fS6O7zqGR4CiSsfvrWveGAbN27mSFdRJ2V22SKlA4Onhwj4YW5C60juWBqwnMEvBwfuOW/jc5JR+q2Ahyk+Yd1RrxLhJv0ydoKFuJopSg/x4yQUconi2cl53hKmfvcrYk5aYH+bI1rxUGegfOHF2L8JU9Y8RhHgC2OaAbhw4iR6gE1aSvb4MxA7W8UBykbP09sPoEhTzaHMLkRe/FvkudHvtNjHRR/PzD6UefMjoXx5MG970h55HT4iHmRCF/jBbqvkcm8cuU1S8JA7tNdufBRoNQ2qjTHwNJXZjE5Og0kgZzFq8viUPoM9dNn4tTRNds3uOmyQhQXMwYVwTL7XH+VHfIRcNbghojHjjB/wzKTZBXuP23V8hof+Nt+q0D5ZD3/yN2o9KLQpNIbieOuGsbhJRA3P8tm10GWEsyT08gc4ufeUm+3zmuhK0UmzYtsW5duLV34G3bPTMHONwqwO3715go3TXptADwQZNcSOcCDGAvVu7CYXAtlw== mohammed a",
  "ssh-rsa DEADBEEF/yJNPZ6e+1uwxCtLABNe8G1NPUdgqh3Q0hIAZ+lirblBDy0uhLaeiCcwOPvSkqn6gHWFZn7ZZ0u8Zfv5rig+/oiZ/M94+LxM2aPLoA9rwR47rviXUwiJ3rjQV4IZzGDuB/p1d7ttaBra39HMkqz5K1Y+I7T9mhCuoU4Rd88NHVx4NmseUQTStdulH6sy+shARMUg2M4PoXEKcWasJUd2s7CuuWa3ZHjL7EQePM1eqgUFPQloac98f3RUVAfVb9AbPhA4t/zewOZS1sYf1kxO6lrGw1P7qbXTmHUR5eTGeW/hKkZSbz5VZeN6ZtihQ3mogzmP+bsDaiuAfF2LQWijwQI7M7xjk7NBjvFfCkmnw1MymSC26vnIrb+ITfPefgi2M+uaL6HXsQvgdEL6VT1pTewD8494UJtPARf472npBWXrMjDpier711rMY5HtSwenq6KE0DHFp1bFXZ+gUZeMzvyIynB4HmyNGZpZf41Lh8uenOy49/ouO9aHMN8lcRLEz9aPQXyjAWT+FooXRQjT+BZWZ3A5t1IJB7Mfbxsah+7wE+CHOtpydL4bDR+wGIR4dm65YegeBviMN2FlCle6CnU2baDK23LTCYJalBV8K17a9ydxvHgelf0nvabTb/f93PQhjQ== jane b",
  "ssh-rsa DEADBEEF/qcBk/rfpzDkeps/0dTRRK/J5OKzIYahAXbGnCx/4Yb6dCHD1gXh1bCwtor6rnQOmOxb8sKl5D5KXBNcjkVC+/m4ugLmHXmMhGJtUbGJPU++4JJ503ZpQQrbUi1jdWm6HoliIRrA2wHbAznUy8Na7GlkQdv9IKWY0DOvslFhATqQ5E4NRoqdQh2uKZm46vqcPBGl64Mfg6+9ggKKDru7gOTkppeCihKzehXR+XCtiGDmnBiMUe3L414E0W5UJ3mTF3kbO5vBdXZp4SZz5aY0de2YmjuoXfAoYqELOhDHJCvkK6p3+BrkuQYV0Z3QRcHwGzW0+jybALWgzhSmnW/7R11BjzRFQdPiXRISh7HXRfUiV38o58qhZiIusgqxjjhFsFDqUQJglkzFfP63sexAwoLwZn7TeAcSf1d351S+rXDVBwbZTlBy1hS/wIMq+4m5nHm3GOgEbrMeSUTSVmaMH+KYAtzs1r94e7B4SXuTi1kCuTd5+yPhVlJVcObe9eZwYSMT6i4VKiIytki5N8+Ht0GqI9XcrJ8re4u2d9krNskfOWGYVnElCH/eviEiUjg9GeME4nZhBkQS3g7bQZsXJrVNEWahKzp8EGsQP4/sV2fDLiZpUCNIBk8SOKc6aLhFrqCp79fEZBEcggLJygZCTYw== Bob c",
  "ssh-rsa DEADBEEF+qkIU+PkKejcjGKc7Yn7yl+oBXR+kxW0LxEbrsMnXnD9PExMoHXWtEquqB3bBsmY3ziuLpoq//VObg/GIBXKLaqeQQBIstDjkwNixnIXunjl2BHECX5S56ADlMkeY6zmKUx3mT+jgWhH7j5tXeBhR9+3JQjuAxCMKsWu+FEEVjLxvEAGmUzD/MmLj1Jj1I9zZAmPJR7di1r7b3MHNGGQWI5nTYNO/qfOxMz6IMJgCqRT2uCrWxxwufjbN4EEt3fPYecfy+9YT6WBsOVXt8CdflbTtFRTbH4uKCADpa4tYUaWnAUiB+AASDZmDVIe82t2L6k25opnD7bcIPW1QC/xVOwVsmKByqnxbDB1mDknwoIVGuxJshcamWxg9x2iEpj0or3YG8EpjZUdZCuK3nFbeGA3cLfa6LOjKik65Q2nRnIj7COQlqPifzNis7RxwLPYvQkaws4ly1bfoMZE2PFaeBgBYp2GEcQRpa19XGI++oMbWIjxfkRUr1g00nmSD5juswWd8Np72RlfzLIK/6Un7Su8bIkRvc673QKqgUuTYrX0yBZZzvEfj+aEJiyeksnqFKXE3G8jzNtl7hAcOzhn+wR/AP4H2qqAbeOtowCm0ATFNUCj2SMxA+6ETKdQX3Gd/3aAGYQ== ci"
]


