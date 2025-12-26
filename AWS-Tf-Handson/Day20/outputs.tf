output "instance_id" {
  description = "ID of the EC2 instance"
  value       = module.my_web_server[*].instance_id
}

output "security_group_id" {
  description = "ID of the Security Group created by the module"
  value       = module.security_group.security_group_id
}

output "vpc_id" {
  value = module.vpc.vpc_id
}