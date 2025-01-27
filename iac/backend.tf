terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "terraform-state-for-vprofile-app-satya"
    key    = "terraform-state/tf-state"
    region = "us-east-1"
  }
}