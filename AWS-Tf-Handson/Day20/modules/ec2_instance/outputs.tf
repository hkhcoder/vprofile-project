output "public_ip" {
  description = "Public IP of the created instance"
  value       = aws_instance.this.public_ip
}

output "instance_id" {
  value = aws_instance.this.id
}