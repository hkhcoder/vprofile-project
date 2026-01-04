resource "aws_cloudwatch_metric_alarm" "denied_requests_alarm" {
  alarm_name          = "DeniedRequestsAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = var.denied_metric_name
  namespace           = var.metric_namespace
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "This metric monitors denied access requests to S3"
  actions_enabled     = true
  alarm_actions       = [var.sns_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "restricted_prefix_alarm" {
  alarm_name          = "RestrictedPrefixAccessAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = var.restricted_metric_name
  namespace           = var.metric_namespace
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "This metric monitors access to restricted prefixes in S3"
  actions_enabled     = true
  alarm_actions       = [var.sns_topic_arn]
}
