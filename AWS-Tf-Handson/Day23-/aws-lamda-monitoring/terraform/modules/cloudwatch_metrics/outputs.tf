output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = var.enable_dashboard ? aws_cloudwatch_dashboard.lambda_monitoring[0].dashboard_name : ""
}

output "dashboard_arn" {
  description = "ARN of the CloudWatch dashboard"
  value       = var.enable_dashboard ? aws_cloudwatch_dashboard.lambda_monitoring[0].dashboard_arn : ""
}

output "metric_namespace" {
  description = "Custom metrics namespace"
  value       = var.metric_namespace
}

output "error_metric_filter_name" {
  description = "Name of the error metric filter"
  value       = aws_cloudwatch_log_metric_filter.lambda_errors.name
}

output "processing_time_metric_filter_name" {
  description = "Name of the processing time metric filter"
  value       = aws_cloudwatch_log_metric_filter.processing_time.name
}

output "success_metric_filter_name" {
  description = "Name of the success metric filter"
  value       = aws_cloudwatch_log_metric_filter.successful_processes.name
}
