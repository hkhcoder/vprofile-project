###################
## Secret modules
###################

module "secrets" {
  source = "./modules/secrets"

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


###################
## Security groups
###################
module "security_groups" {
  source = "./modules/security_groups"

  project_name     = var.project_name
  environment      = var.environment
  vpc_id           = module.vpc.vpc_id
}

###################
## RDS modules
################### 
module "rds" {
  source = "./modules/rds"

  project_name             = var.project_name
  environment              = var.environment
  private_subnets_id       = module.vpc.private_subnets
  db_name                  = var.db_name
  db_password              = module.secrets.db_password  
  db_username              = var.db_username
  db_security_group_id     = module.security_groups.db_sg_id
  engine_version           = var.db_engine_version
  instance_class           = var.db_instance_class
  region                   = var.aws_region
  allocated_storage        = var.db_allocated_storage
  
}

###################
## EC2 modules
###################
module "ec2" {
  source = "./modules/ec2"  
    
  project_name          = var.project_name
  #environment           = var.environment
  instance_type         = var.ec2_instance_type
  public_subnets        = module.vpc.public_subnets
  web_security_group_id = module.security_groups.web_sg_id
  db_endpoint           = module.rds.db_endpoint
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = module.secrets.db_password
}
