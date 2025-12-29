resource "random_password" "password" {
  length = 16
  special = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_id" "name" {
  byte_length = 4
}

resource "aws_secretsmanager_secret" "this" {
  name        = "${var.project_name}-${var.environment}-db-password-${random_id.name.result}"
  description = var.description

    tags = {
        Project     = var.project_name
        Environment = var.environment
    }
}

resource "aws_secretsmanager_secret_version" "dblogininfo" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.name.result
    engine   = "mysql"
    host     = "" # Will be automatically filled after RDS creation
    port     = 3306
  })
}