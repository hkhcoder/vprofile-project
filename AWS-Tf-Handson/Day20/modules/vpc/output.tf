output "vpc_id" {
  value = module.vpc.vpc_id
}

output "name" {
  value = module.vpc.name
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}