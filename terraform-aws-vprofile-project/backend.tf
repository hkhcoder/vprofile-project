terraform {
  backend "s3" {
    bucket = "terraformstate32456"
    key    = "terraform/backend"
    region = "us-east-1"
  }
}