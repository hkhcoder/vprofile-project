variable "ami_id" {
  description = "The AMI ID to deploy"
  type        = string
}

variable "instance_type" {
  description = "The instance type (e.g., t2.micro)"
  type        = string
  default     = "t3.micro"
}

variable "instance_name" {
  description = "The name tag for the instance"
  type        = string
}

variable "security_group_id" {
  description = "The Security Group ID to attach to the instance"
  type        = string
}