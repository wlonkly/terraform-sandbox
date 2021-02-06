resource "aws_s3_bucket" "state" {
  bucket = "rlafferty-lfs-k8s-tf-state"
  acl    = "private"

  tags = {
    "pd:owner" = "rlafferty"
    "pd:repo"  = "wlonkly/terraform-sandbox"
    "pd:terraform" = "true"
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
    bucket = "rlafferty-lfs-k8s-tf-state"
    key    = "terraform.tfstate"
    region = "ca-central-1"
  }
}

