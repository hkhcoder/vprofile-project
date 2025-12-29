variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-west-1"
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "aws-config-terraform"
  
}