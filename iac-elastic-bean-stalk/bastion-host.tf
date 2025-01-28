data "aws_ami" "Ubuntu22ami" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20250112"]
  }

}

output "ami" {
  value = data.aws_ami.Ubuntu22ami.id
}

resource "aws_instance" "vprofile-bastion-host" {
  ami = data.aws_ami.Ubuntu22ami.id

  instance_type = "t3.micro"

  key_name = aws_key_pair.vprofilekey.key_name

  subnet_id = module.vpc.public_subnets[0]

  count = var.instance_count

  vpc_security_group_ids = [aws_security_group.vprofile-bastion-sg.id]

  tags = {
    Name    = "vprofile-bastion"
    Project = var.PROJECT
  }

  connection {
    type        = "ssh"
    user        = var.USERNAME
    private_key = file(var.PRIV_KEY_PATH)
    host        = self.public_ip
  }

  provisioner "file" {
    content     = templatefile("templates/db-deploy.tmpl", { rds-endpoint = aws_db_instance.vprofile-rds.address, dbuser = var.dbuser, dbpass = var.dbpass })
    destination = "/tmp/vprofile-dbdeploy.sh"
  }

  provisioner "file" {
    source      = "templates/accountsdb.sql"
    destination = "/tmp/accountsdb.sql"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/vprofile-dbdeploy.sh",
      "sudo /tmp/vprofile-dbdeploy.sh"
    ]
  }

  depends_on = [aws_db_instance.vprofile-rds, aws_elastic_beanstalk_environment.vprofile-bean-prod]
}