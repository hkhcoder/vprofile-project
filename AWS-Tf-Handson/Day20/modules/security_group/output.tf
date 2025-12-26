output "security_group_id" {
  value = aws_security_group.this.id
}

output "security_group_name" {
  value = aws_security_group.this.name
}

output "vpc_id" {
  value = aws_security_group.this.vpc_id
}