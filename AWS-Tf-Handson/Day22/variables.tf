variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-west-1"
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "aws-rds-handson"
  
}

variable "db_username" {
  description = "The username for the database"
  type        = string
  default     = "adminuser"
}

variable "environment" {
  description = "value"
  default = "dev"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = module.vpc.vpc_cidr
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = string
  default     = module.vpc.public_subnets
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = module.vpc.private_subnets
}