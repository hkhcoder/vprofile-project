output "error_alarm_arn" {
  description = "ARN of the error rate alarm"
  value       = aws_cloudwatch_metric_alarm.lambda_errors.arn
}

output "duration_alarm_arn" {
  description = "ARN of the duration alarm"
  value       = aws_cloudwatch_metric_alarm.lambda_duration.arn
}

output "throttle_alarm_arn" {
  description = "ARN of the throttle alarm"
  value       = aws_cloudwatch_metric_alarm.lambda_throttles.arn
}

output "concurrency_alarm_arn" {
  description = "ARN of the concurrent executions alarm"
  value       = aws_cloudwatch_metric_alarm.concurrent_executions.arn
}

output "log_error_alarm_arn" {
  description = "ARN of the log error alarm"
  value       = aws_cloudwatch_metric_alarm.log_errors.arn
}

output "success_rate_alarm_arn" {
  description = "ARN of the success rate alarm"
  value       = aws_cloudwatch_metric_alarm.low_success_rate.arn
}

output "all_alarm_names" {
  description = "List of all alarm names"
  value = [
    aws_cloudwatch_metric_alarm.lambda_errors.alarm_name,
    aws_cloudwatch_metric_alarm.lambda_duration.alarm_name,
    aws_cloudwatch_metric_alarm.lambda_throttles.alarm_name,
    aws_cloudwatch_metric_alarm.concurrent_executions.alarm_name,
    aws_cloudwatch_metric_alarm.log_errors.alarm_name,
    aws_cloudwatch_metric_alarm.low_success_rate.alarm_name
  ]
}
