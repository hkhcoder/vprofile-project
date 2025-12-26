resource "aws_instance" "name" {
  ami           = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [var.security_group_id]
  subnet_id     = var.subnet_id
  

  tags = {
    Name = var.instance_name
  }
}
