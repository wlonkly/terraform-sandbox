provider "aws" {
   region = "${var.region}"
}

resource "aws_route53_zone" "rich-dev_net" {
   name = "rich-dev.net"
}

output "rich-dev_net_nameservers" {
   value = "${aws_route53_zone.rich-dev_net.name_servers}"
}
