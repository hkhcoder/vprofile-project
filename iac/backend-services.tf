resource "aws_db_subnet_group" "vprofile-rds-subnet-group"{
    name = "vprofile-rds-subnet-group"
    subnet_ids = [module.vpc.private_subnets[0],module.vpc.private_subnets[1],module.vpc.private_subnets[2]]
    tags = {
      Name = "Subnet group for RDS."
    }
}

resource "aws_elasticache_subnet_group" "vprofile-elastic-cache-subnet-group" {
  name = "vprofile-elastic-cache-subnet-group"
  subnet_ids = [module.vpc.private_subnets[0],module.vpc.private_subnets[1],module.vpc.private_subnets[2]]
    tags = {
      Name = "Subnet group for Elastic cache."
    }
}

