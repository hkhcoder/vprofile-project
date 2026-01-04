output "timeout_alarm_arn" {
  description = "ARN of the timeout alarm"
  value       = aws_cloudwatch_metric_alarm.timeout_alarm.arn
}

output "memory_alarm_arn" {
  description = "ARN of the memory alarm"
  value       = aws_cloudwatch_metric_alarm.memory_alarm.arn
}

output "pil_alarm_arn" {
  description = "ARN of the PIL/image processing alarm"
  value       = aws_cloudwatch_metric_alarm.pil_alarm.arn
}

output "s3_permission_alarm_arn" {
  description = "ARN of the S3 permission alarm"
  value       = aws_cloudwatch_metric_alarm.s3_permission_alarm.arn
}

output "critical_alarm_arn" {
  description = "ARN of the critical error alarm"
  value       = aws_cloudwatch_metric_alarm.critical_alarm.arn
}

output "large_image_alarm_arn" {
  description = "ARN of the large image warning alarm"
  value       = aws_cloudwatch_metric_alarm.large_image_alarm.arn
}

output "all_log_alarm_names" {
  description = "List of all log-based alarm names"
  value = [
    aws_cloudwatch_metric_alarm.timeout_alarm.alarm_name,
    aws_cloudwatch_metric_alarm.memory_alarm.alarm_name,
    aws_cloudwatch_metric_alarm.pil_alarm.alarm_name,
    aws_cloudwatch_metric_alarm.s3_permission_alarm.alarm_name,
    aws_cloudwatch_metric_alarm.critical_alarm.alarm_name,
    aws_cloudwatch_metric_alarm.large_image_alarm.alarm_name
  ]
}
