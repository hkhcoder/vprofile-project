output "denied_alarm_arn" {
  value = aws_cloudwatch_metric_alarm.denied_requests_alarm.arn
}

output "restricted_alarm_arn" {
  value = aws_cloudwatch_metric_alarm.restricted_prefix_alarm.arn
}
