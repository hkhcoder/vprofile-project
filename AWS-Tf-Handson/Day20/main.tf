# 1. Get the latest Ubuntu AMI (Just like Day 19)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# 2. Call the Module
module "my_web_server" {
  # SOURCE: Where is the module code?
  source = "./modules/ec2_instance"

  # INPUTS: Passing values to the module's variables
  ami_id        = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  instance_name = "Module-Demo-Server"
}

# 3. Display Outputs from the Module
output "server_ip" {
  value = module.my_web_server.public_ip
}