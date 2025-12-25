output "aws_instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.instance.public_ip
  
}


output "aws_instance" {
  value = aws_instance.instance.id
  description = "Instance Id"
}

output "aws_security_group_id" {
  value       = aws_security_group.ssh_access.id
  description = "Security Group Id"
}


output "aws_profile" {
  value       = "468284643560"
  description = "AWS Profile used"  
}