provider "aws" {
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