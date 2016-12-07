provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_s3_bucket" "kops_state" {
    bucket = "kops-kops.${var.domain}"
    acl = "private"
}

output "kops_s3_arn" {
   value = "${aws_s3_bucket.kops_state.arn}"
}

resource "aws_route53_zone" "rich-dev" {
   name = "${var.domain}"
}


resource "aws_route53_zone" "kops_zone" {
   name = "kops.${var.domain}"
}

output "rich-dev_nameservers" {
   value = "${aws_route53_zone.rich-dev.name_servers}"
}

output "kops_zone_nameservers" {
   value = "${aws_route53_zone.kops_zone.name_servers}"
}