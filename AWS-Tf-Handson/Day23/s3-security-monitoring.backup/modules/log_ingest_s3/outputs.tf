output "log_group_name" {
  value = aws_cloudwatch_log_group.s3_access_logs.name
}

output "monitored_bucket_name" {
  value = aws_s3_bucket.monitored_bucket.id
}
