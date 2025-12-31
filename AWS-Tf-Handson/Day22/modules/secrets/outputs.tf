output "db_password" {
  value     = random_password.password.result
  sensitive = true
}
