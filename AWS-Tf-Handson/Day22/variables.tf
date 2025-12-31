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

variable "environment" {
  description = "value"
  default = "dev"
}

# VPC related variables
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.3.0/24"]
}

# RDS related variables
variable "db_username" {
  description = "The username for the database"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "db_name" {
  description = "The name of the database"
  type        = string
  default     = "webappdb"
}

variable "db_allocated_storage" {
  description = "The allocated storage for the database in GB"
  type        = number
  default     = 10
}

variable "db_engine_version" {
  description = "The database engine version to use"
  type        = string
  default     = "8.0"
}

variable "db_instance_class" {
  description = "The Db instance class"
  type        = string
  default     = "db.t3.micro"
}

# EC2 related variables
variable "ec2_instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
  default     = "t3.micro"
}