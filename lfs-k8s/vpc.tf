provider "aws" {
  region     = "ca-central-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "rlafferty-lfs-k8s-vpc"
  cidr = "10.21.0.0/22"

  azs             = ["ca-central-1a", "ca-central-1b", "ca-central-1d"]
  public_subnets  = ["10.21.0.0/24", "10.21.1.0/24", "10.21.2.0/24"]

  tags = {
    "pd:terraform" = "true"
    "pd:repo" = "wlonkly/terraform-sandbox"
    "pd:owner" = "rlafferty"
  }
}

