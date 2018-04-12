resource "aws_route53_zone" "kops-subdomain" {
  name = "${var.dns_domain}"

  tags {
    Owner = "rlafferty"
  }
}

output "nameservers" {
   value = "${aws_route53_zone.kops-subdomain.name_servers}"
}

