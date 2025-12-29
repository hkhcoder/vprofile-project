output "vpc_id" {
  value = aws_vpc.name.id
}

output "public_subnets" {
  value = aws_subnet.public_subnet.*.id
}

output "private_subnets" {
  value = aws_subnet.private_subnets.*.id
}

output "aws_internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}

output "aws_route_table_id" {
  value = aws_route_table.rtb.id
}

output "aws_route_table_association" {
  value = aws_route_table_association.public_rta
}