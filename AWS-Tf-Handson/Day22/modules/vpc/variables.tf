variable "project_name" {
  description = "Name of the project"
  type = "string"
}

variable "environment" {
  description = "Environment name"
  type = "string"
}

variable "vpc_cidr" {
  description = "CIDR range for the VPC"
  type = "string"
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Public subnet"
  type = string
  default = "10.0.1.0/24"
}

variable "private_subnets" {
  description = "Private subnet"
  type = list(string)
  default = ["10.0.2.0/24", "10.0.3.0/24"]
}

variable "aws_region" {
  description = "AWS region for the subnet"
  type = "string"
}