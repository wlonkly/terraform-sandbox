resource "aws_s3_bucket" "pd-rlafferty-terraform" {
    bucket = "pd-rlafferty-terraform"
 
    versioning {
      enabled = true
    }
 
    lifecycle {
      prevent_destroy = true
    }
 
    tags {
      Name = "rlafferty S3 remote terraform state store"
      Owner = "Rich Lafferty"
    }      
}

resource "aws_s3_bucket" "pd-rlafferty-kops" {
    bucket = "pd-rlafferty-kops"

    versioning {
      enabled = true
    }

    lifecycle {
      prevent_destroy = true
    }

    tags {
      Name = "rlafferty S3 remote kops state store"
      Owner = "rlafferty"
    }
}

