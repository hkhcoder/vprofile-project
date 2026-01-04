# ============================================================================
# S3 BUCKET OUTPUTS
# ============================================================================

output "upload_bucket_name" {
  description = "S3 bucket for uploading images (SOURCE)"
  value       = module.s3_buckets.upload_bucket_id
}

output "processed_bucket_name" {
  description = "S3 bucket for processed images (DESTINATION)"
  value       = module.s3_buckets.processed_bucket_id
}

output "upload_bucket_arn" {
  description = "ARN of the upload bucket"
  value       = module.s3_buckets.upload_bucket_arn
}

output "processed_bucket_arn" {
  description = "ARN of the processed bucket"
  value       = module.s3_buckets.processed_bucket_arn
}

# ============================================================================
# LAMBDA FUNCTION OUTPUTS
# ============================================================================

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = module.lambda_function.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = module.lambda_function.function_arn
}

output "lambda_log_group_name" {
  description = "CloudWatch Log Group name for Lambda"
  value       = module.lambda_function.log_group_name
}

# ============================================================================
# SNS TOPICS OUTPUTS
# ============================================================================

output "critical_alerts_topic_arn" {
  description = "ARN of the critical alerts SNS topic"
  value       = module.sns_notifications.critical_alerts_topic_arn
}

output "performance_alerts_topic_arn" {
  description = "ARN of the performance alerts SNS topic"
  value       = module.sns_notifications.performance_alerts_topic_arn
}

output "log_alerts_topic_arn" {
  description = "ARN of the log alerts SNS topic"
  value       = module.sns_notifications.log_alerts_topic_arn
}

# ============================================================================
# CLOUDWATCH MONITORING OUTPUTS
# ============================================================================

output "cloudwatch_dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = module.cloudwatch_metrics.dashboard_name
}

output "cloudwatch_dashboard_url" {
  description = "URL to access the CloudWatch dashboard"
  value       = var.enable_cloudwatch_dashboard ? "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${module.cloudwatch_metrics.dashboard_name}" : "Dashboard not enabled"
}

output "metric_namespace" {
  description = "Custom CloudWatch metrics namespace"
  value       = var.metric_namespace
}

# ============================================================================
# ALARM OUTPUTS
# ============================================================================

output "cloudwatch_alarms" {
  description = "List of all CloudWatch alarm names"
  value = {
    error_alarm       = module.cloudwatch_alarms.all_alarm_names[0]
    duration_alarm    = module.cloudwatch_alarms.all_alarm_names[1]
    throttle_alarm    = module.cloudwatch_alarms.all_alarm_names[2]
    concurrency_alarm = module.cloudwatch_alarms.all_alarm_names[3]
    log_error_alarm   = module.cloudwatch_alarms.all_alarm_names[4]
    success_rate_alarm = module.cloudwatch_alarms.all_alarm_names[5]
  }
}

output "log_based_alarms" {
  description = "List of all log-based alarm names"
  value = {
    timeout_alarm      = module.log_alerts.all_log_alarm_names[0]
    memory_alarm       = module.log_alerts.all_log_alarm_names[1]
    pil_alarm          = module.log_alerts.all_log_alarm_names[2]
    s3_permission_alarm = module.log_alerts.all_log_alarm_names[3]
    critical_alarm     = module.log_alerts.all_log_alarm_names[4]
    large_image_alarm  = module.log_alerts.all_log_alarm_names[5]
  }
}

# ============================================================================
# USAGE INFORMATION
# ============================================================================

output "aws_region" {
  description = "AWS Region where resources are deployed"
  value       = var.aws_region
}

output "upload_command_example" {
  description = "Example AWS CLI command to upload an image"
  value       = "aws s3 cp your-image.jpg s3://${module.s3_buckets.upload_bucket_id}/"
}

output "view_logs_command" {
  description = "AWS CLI command to view Lambda logs"
  value       = "aws logs tail ${module.lambda_function.log_group_name} --follow"
}

output "test_alarm_command" {
  description = "AWS CLI command to test alarms by setting alarm state"
  value       = "aws cloudwatch set-alarm-state --alarm-name ${module.cloudwatch_alarms.all_alarm_names[0]} --state-value ALARM --state-reason 'Testing alarm'"
}

output "sns_subscription_note" {
  description = "Important note about SNS email subscriptions"
  value       = var.alert_email != "" ? "⚠️  IMPORTANT: Check your email (${var.alert_email}) and confirm SNS subscription(s) to receive alerts!" : "No email configured for alerts"
}
