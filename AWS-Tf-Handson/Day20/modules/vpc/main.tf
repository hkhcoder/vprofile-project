module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0" # It is highly recommended to pin a specific version

  name = "my-vpc"
  cidr = var.cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}