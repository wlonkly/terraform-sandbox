variable "region" {
  default = "ca-central-1"
}

variable "subnets" {
  type = map(string)

  default = {
    "ca-central-1a" = "10.1.1.0/24"
    "ca-central-1b" = "10.1.2.0/24"
  }
}

variable "vpc_cidr" {
  default = "10.1.0.0/16"
}

# variable "dns_zone" {
#   default = "rlafferty-eks.pd-development.com"
# }

