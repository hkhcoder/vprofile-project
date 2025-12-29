# RDS Module

resource "aws_db_subnet_group" "default" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnets_id

  tags = {
    Name = "${var.project_name}-db-subnet-group"
    Environment = "Demo"
  }
}

resource "aws_db_instance" "default" {
  identifier              = "${var.project_name}-db-instance"
  allocated_storage       = var.allocated_storage
  storage_type            = "gp2"
  engine                  = "mysql"
  engine_version          = var.engine_version
  instance_class          = var.instance_class 
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  parameter_group_name    = "default.mysql8.0"
  db_subnet_group_name    = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids  = [var.db_security_group_id]
  skip_final_snapshot     = true
  publicly_accessible     = true


  tags = {
    Name = "${var.project_name}-db-instance"
    Environment = "Demo"
  }
}