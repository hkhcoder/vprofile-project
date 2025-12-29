# Security Groups Module

resource "aws_security_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "Security group for web server to allow HTTP and SSH traffic"
  vpc_id      = var.vpc_id

    ingress {
        description = "HTTP access to web server"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "SSH access to web server"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        description = "Allow all outbound traffic"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.project_name}-web-sg"
  }
}

# Database Security Groups Module

resource "aws_security_group" "db" {
  name        = "${var.project_name}-db-sg"
  description = "Security group for database to allow traffic from web server"
  vpc_id      = var.vpc_id

    ingress {
        description = "Allow MySQL traffic from web server"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        security_groups = [aws_security_group.web.id]
    }

    egress {
        description = "Allow all outbound traffic"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.project_name}-db-sg"
        environment = var.environment
  }
}

