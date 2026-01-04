terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
  profile = "468284643560"

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "AWS-Production-Infrastructure"
      ManagedBy   = "Terraform"
    }
  }
}
