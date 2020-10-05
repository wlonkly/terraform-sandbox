resource "aws_s3_bucket" "state" {
  bucket = "rlafferty-pd-sandbox-eks-tf-state"
  acl    = "private"

  tags = {
    owner = "rlafferty"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }

}

terraform {
  backend "s3" {
    bucket = "rlafferty-pd-sandbox-eks-tf-state"
    key    = "terraform.tfstate"
    region = "ca-central-1"
  }
}

