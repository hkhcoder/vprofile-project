output "public_ip" {
  description = "Public IP of the created instance"
  value       = aws_instance.name.public_ip
}

output "instance_id" {
  value = aws_instance.name.id
}
