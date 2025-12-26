data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

#data "aws_vpc" "default" {
#  default = true
#}

# 1. Call the Security Group Module
module "security_group" {
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc_id
}


# 2. Call the Module
module "my_web_server" {
  # SOURCE: Where is the module code?
  source = "./modules/ec2_instance"

# 3. Using count to create multiple instances
  count = var.instance_count

  # INPUTS: Passing values to the module's variables
  ami_id        = data.aws_ami.ubuntu.id
  instance_type = var.instance_type # You can define this variable in main.tf or hardcode a value
  instance_name = var.instance_name

  # New input for security group ID
  security_group_id = module.security_group.security_group_id # Replace with your actual security group ID

  # Input for Subnet ID is required to launch the instance in the specific VPC
  subnet_id = module.vpc.public_subnets[0] # Using the first public subnet from the VPC module
}

#Call the VPC module  
module "vpc" {
  source = "./modules/vpc"
}
