provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

module "consul" {
    source = "github.com/hashicorp/consul/terraform/aws"

    key_name = "awstest"
    key_path = "~/.ssh/id_rsa.aws"
    region = "us-east-1"
    servers = "3"
}

output "consul_address" {
    value = "${module.consul.server_address}"
}