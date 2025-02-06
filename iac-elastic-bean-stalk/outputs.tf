output "cluster_name" {
  description = "AWS EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for AWS EKS"
  value       = module.eks.cluster_endpoint
}

output "region" {
  description = "AWS EKS cluster region"
  value       = var.AWS_REGION
}

output "cluster_security_group_id" {
  description = "Secuity group id for the AWS EKS cluster"
  value       = module.eks.cluster_security_group_id
}