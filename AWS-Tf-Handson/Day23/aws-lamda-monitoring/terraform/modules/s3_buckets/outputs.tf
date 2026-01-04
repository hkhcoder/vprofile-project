output "upload_bucket_id" {
  description = "ID of the upload S3 bucket"
  value       = aws_s3_bucket.upload_bucket.id
}

output "upload_bucket_arn" {
  description = "ARN of the upload S3 bucket"
  value       = aws_s3_bucket.upload_bucket.arn
}

output "processed_bucket_id" {
  description = "ID of the processed S3 bucket"
  value       = aws_s3_bucket.processed_bucket.id
}

output "processed_bucket_arn" {
  description = "ARN of the processed S3 bucket"
  value       = aws_s3_bucket.processed_bucket.arn
}

output "upload_bucket_domain_name" {
  description = "Domain name of the upload bucket"
  value       = aws_s3_bucket.upload_bucket.bucket_domain_name
}

output "processed_bucket_domain_name" {
  description = "Domain name of the processed bucket"
  value       = aws_s3_bucket.processed_bucket.bucket_domain_name
}
