variable "region" {
  default = "ca-central-1"
}

variable "amis" {
  type = "map"
  default = {
    us-east-1 = "ami-0b33d91d"
    us-east-2 = "ami-c55673a0"
    us-west-2 = "ami-f173cc91"
    ca-central-1 = "ami-ebed508f"
  }
}
