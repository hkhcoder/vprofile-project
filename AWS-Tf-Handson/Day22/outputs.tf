output "ec2_instance_id" {
  value = module.ec2.instance_id
}

output "ec2_instance_ip" {
  value = module.ec2.public_ip
}

output "random_endpoint" {
  value = module.rds.db_endpoint
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "application_url" {
  value = "http://${module.ec2.public_ip}"
}

output "database_name" {
  value = module.rds.db_name
}


output "database_port" {
  value = module.rds.db_port
}