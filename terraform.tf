terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.46.0"
    }

    random = {
      source = "hashicorp/random"
      version = "~> 3.4.3"
    }

    tls = {
      source = "hashicorp/tls"
      version = "~> 4.0.4"
    }

    cloudinit = {
      source = "hashicorp/cloudinit"
      version = "~> 2.2.0"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.16.1"
    }
  }

  backend "s3" {
    bucket         	   = "gitlab-terraform1"
    key              	   = "state/terraform.tfstate"
    region         	   = "us-east-1"
    #encrypt        	   = true
    #dynamodb_table = "mycomponents_tf_lockid"
  }

  required_version = "~> 1.3"
}
