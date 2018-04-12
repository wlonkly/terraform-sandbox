variable "vpc_cidr_block" {
  default = "10.25.0.0/16"
}

variable "region" {
  default = "ca-central-1"
}

variable azs {
  default = ["ca-central-1a", "ca-central-1b"]
}

variable dns_domain {
  default = "rlkops.pd-development.com"
}
