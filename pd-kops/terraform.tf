terraform {
 backend "s3" {
 encrypt = true
 bucket = "pd-rlafferty-terraform"
 region = "ca-central-1"
 key = "terraform.tfstate"
 }
}

