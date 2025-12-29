# EC2 module

# Get latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_instance" "example" {
  ami                           = data.aws_ami.ubuntu.id
  instance_type                 = var.instance_type
  subnet_id                     = var.public_subnets
  vpc_security_group_ids        = [var.web_security_group_id]
  associate_public_ip_address   = true

  user_data = templatefile("${path.module}/template/user_data.sh", {
    db_host         = var.db_endpoint
    db_username     = var.db_username
    db_password     = var.db_password
    db_name         = var.db_name
  })
  tags = {
    Name = "${var.project_name}-ec2"
  }
}