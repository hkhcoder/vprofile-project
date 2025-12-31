#output "db_password" {
#  value = random_password.password.result
#}

output "secret_arn" {
  value = aws_secretsmanager_secret.this.arn
}