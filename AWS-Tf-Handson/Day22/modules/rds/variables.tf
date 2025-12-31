variable "private_subnets_id" {
  type = list(string)
}

variable "project_name" {
  type = string
}

variable "allocated_storage" {
  type = number
}

variable "engine_version" {
  type = string
}

variable "instance_class" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "db_security_group_id" {
  type = string
}

variable "environment" {
  type = string 
}

variable "region" {
  type = string

}