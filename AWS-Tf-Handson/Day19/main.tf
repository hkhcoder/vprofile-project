terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  # Backend configuration example is placed in backend.tf (commented out by default)
}

# EC2 instance used for provisioner demos.
# Each provisioner block is included below but wrapped in block comments (/* ... */).
# For the demo, uncomment one provisioner block at a time, then `terraform apply`.

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

##########################################################
# Create a security group to allow SSH access from anywhere.
##########################################################
resource "aws_security_group" "ssh_access" {
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow all outbound traffic"
}
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH access"
  }
}

resource "aws_instance" "instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.ssh_access.id]


  tags = {
    Name = "AWS-Tf-Handson-Day19"
  }

#provisioner "local-exec" {
#    command = "echo Instance ${self.id} has been created with IP ${self.public_ip}"
#  }
#}

provisioner "remote-exec" {
  inline = [
    "echo 'Instance ${self.id} has been created with IP ${self.public_ip}'",
    "sudo apt-get update -y",
    "echo 'Provisioning complete!' | tee /home/ubuntu/provisioning.log"
  ]
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${path.module}/terraform-demo-key.pem")
    host        = self.public_ip
  }
}
  provisioner "file" {
    source      = "${path.module}/scripts/welcome.sh"
    destination = "/home/ubuntu/welcome.sh"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${path.module}/terraform-demo-key.pem")
      host        = self.public_ip
}
}
}