resource "aws_s3_bucket" "state" {
  bucket = "rlafferty-pd-sandbox-testing-tf-state"
  acl    = "private"

  tags = {
    owner = "rlafferty"
  }
}

terraform {
  backend "s3" {
    bucket = "rlafferty-pd-sandbox-testing-tf-state"
    key    = "terraform.tfstate"
    region = "ca-central-1"
  }
}

