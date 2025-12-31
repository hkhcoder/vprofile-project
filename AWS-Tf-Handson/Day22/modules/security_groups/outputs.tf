output "db_sg_id" {
  value = aws_security_group.db.id
}

output "web_sg_id" {
  value = aws_security_group.web.id
}
