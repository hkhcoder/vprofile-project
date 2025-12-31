#------------------------------
# VPC Module
#------------------------------
resource "aws_vpc" "name" {
  cidr_block = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
    Environment = var.environment
  }
}

#------------------------------
# Public Subnet Module
#------------------------------

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.name.id
  cidr_block = var.public_subnets
  map_public_ip_on_launch = true
  availability_zone = "${var.aws_region}a"

      tags = {
        Name = "${var.project_name}-subnet"
    }
}

#------------------------------
# Private Subnet Module for RDS
#------------------------------ 
resource "aws_subnet" "private_1" {
  vpc_id = aws_vpc.name.id
  cidr_block = var.private_subnets[0]
  availability_zone = "${var.aws_region}a"

      tags = {
        Name = "${var.project_name}-private-subnet-1"
    }
}

resource "aws_subnet" "private_2" {
  vpc_id = aws_vpc.name.id
  cidr_block = var.private_subnets[1]
  availability_zone = "${var.aws_region}c"

      tags = {
        Name = "${var.project_name}-private-subnet-2"
    }
}

#------------------------------
# Internet Gateway Module
#------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.name.id

      tags = {
        Name = "${var.project_name}-igw"
        Environment = var.environment
    }
}

#------------------------------
# Route Table Module
#------------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.name.id

    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
    }

      tags = {
        Name = "${var.project_name}-public-rt"
        Environment = var.environment
    }
}

#------------------------------
# Route Table Association Module
#------------------------------ 
resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}
