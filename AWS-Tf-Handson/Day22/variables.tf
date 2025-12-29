variable "region" {
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