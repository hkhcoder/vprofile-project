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

  project_name             = "${var.project_name}-${var.environment}-vpc"
  environment      = var.environment
  aws_region       = var.aws_region
  vpc_cidr         = var.vpc_cidr
  private_subnets  = var.private_subnets
  public_subnets   = var.public_subnets
}