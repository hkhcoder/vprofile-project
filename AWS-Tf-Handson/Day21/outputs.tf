#######################
## IAM Policy Outputs##
#######################

output "mfa_delete_policy_arn" {
  description = "The ARN of the MFA delete policy"
  value       = aws_iam_policy.mfa_delete_policy.arn
}

output "s3_encryption_policy" {
  description = "The ARN of the S3 encryption policy"
  value       = aws_iam_policy.config_s3_policy.arn
}

output "config_role_arn" {
  description = "The ARN of the AWS Config IAM role"
  value       = aws_iam_role.config_role.arn
}

output "demo_user" {
  description = "The name of the demo IAM user"
  value = aws_iam_user.demo_user.id
}

#######################
## S3 Bucket Outputs##
#######################

output "s3_bucket_name" {
  description = "The name of the S3 bucket for AWS Config"
  value       = aws_s3_bucket.config_bucket.bucket
}   

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket for AWS Config"
  value       = aws_s3_bucket.config_bucket.arn
}   

output "versioning" {
  description = "Whether versioning is enabled or not on S3 bucket"
  value       = aws_s3_bucket_versioning.versioning_example.versioning_configuration[0].status
}

#######################
## AWS Config Outputs##
#######################

output "config_recorder_name" {
  description = "The name of the AWS Config configuration recorder"
  value       = aws_config_configuration_recorder.main.name
}   

output "config_recorder_id" {
  description = "The ID of the AWS Config configuration recorder"
  value       = aws_config_configuration_recorder.main.id
}       

output "delivery_channel_name" {
  description = "The name of the AWS Config delivery channel"
  value       = aws_config_delivery_channel.main.name
}           


output "delivery_channel_s3_bucket_name" {
  description = "The name of the S3 bucket for AWS Config delivery channel"
  value       = aws_config_delivery_channel.main.s3_bucket_name
}

output "region" {
  description = "The AWS region where resources are deployed"
  value       = var.region
}
