variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Name of the Elastic Beanstalk application"
  type        = string
  default     = "my-app-bluegreen"
}

variable "solution_stack_name" {
  description = "Elastic Beanstalk solution stack name (platform)"
  type        = string
  # Node.js 20 running on 64bit Amazon Linux 2023
  default = "64bit Amazon Linux 2023 v6.6.8 running Node.js 20"
}

variable "instance_type" {
  description = "EC2 instance type for Elastic Beanstalk environments"
  type        = string
  default     = "t3.micro"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "BlueGreenDeployment"
    Environment = "Demo"
    ManagedBy   = "Terraform"
  }
}