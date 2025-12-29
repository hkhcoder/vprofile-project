###################
## Secret modules
###################

module "secret" {
  source = "./modules/secret"

  project_name        = var.project_name
  environment         = var.environment
  description         = "This is my secret"
  db_username        =  var.db_username
}


###################
## VPC modules
###################
module "vpc" {
  source = "./modules/vpc"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}