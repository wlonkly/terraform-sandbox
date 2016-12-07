provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_route53_zone" "rich-dev_net" {
   name = "rich-dev.net"
}

output "rich-dev_net_nameservers" {
   value = "${aws_route53_zone.rich-dev_net.name_servers}"
}
