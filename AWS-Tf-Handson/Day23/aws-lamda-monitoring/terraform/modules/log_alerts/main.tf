# ============================================================================
# LOG ALERTS MODULE
# Creates log-based metric filters and alarms for specific error patterns
# Documentation
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm
# ============================================================================

# Metric Filter: Timeout Errors
resource "aws_cloudwatch_log_metric_filter" "timeout_errors" {
  name           = "${var.function_name}-timeout-errors"
  log_group_name = var.log_group_name
  pattern        = "Task timed out"

  metric_transformation {
    name          = "TimeoutErrors"
    namespace     = var.metric_namespace
    value         = "1"
    default_value = "0"
  }
}

# Alarm: Timeout Errors
resource "aws_cloudwatch_metric_alarm" "timeout_alarm" {
  alarm_name          = "${var.function_name}-timeout-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "TimeoutErrors"
  namespace           = var.metric_namespace
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Triggers when Lambda function times out"
  actions_enabled     = true
  alarm_actions       = [var.log_alerts_topic_arn]
  treat_missing_data  = "notBreaching"

  tags = merge(
    var.tags,
    {
      Name     = "${var.function_name}-timeout-alarm"
      Type     = "LogBased"
      Severity = "Critical"
    }
  )
}

# Metric Filter: Out of Memory Errors
resource "aws_cloudwatch_log_metric_filter" "memory_errors" {
  name           = "${var.function_name}-memory-errors"
  log_group_name = var.log_group_name
  pattern        = "?\"MemoryError\" ?\"Runtime exited with error: signal: killed\""

  metric_transformation {
    name          = "MemoryErrors"
    namespace     = var.metric_namespace
    value         = "1"
    default_value = "0"
  }
}

# Alarm: Memory Errors
resource "aws_cloudwatch_metric_alarm" "memory_alarm" {
  alarm_name          = "${var.function_name}-memory-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "MemoryErrors"
  namespace           = var.metric_namespace
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Triggers when Lambda runs out of memory"
  actions_enabled     = true
  alarm_actions       = [var.log_alerts_topic_arn]
  treat_missing_data  = "notBreaching"

  tags = merge(
    var.tags,
    {
      Name     = "${var.function_name}-memory-alarm"
      Type     = "LogBased"
      Severity = "Critical"
    }
  )
}

# Metric Filter: PIL/Image Processing Errors
resource "aws_cloudwatch_log_metric_filter" "pil_errors" {
  name           = "${var.function_name}-pil-errors"
  log_group_name = var.log_group_name
  pattern        = "?\"PIL\" ?\"Image processing failed\" ?\"cannot identify image\""

  metric_transformation {
    name          = "ImageProcessingErrors"
    namespace     = var.metric_namespace
    value         = "1"
    default_value = "0"
  }
}

# Alarm: PIL Errors
resource "aws_cloudwatch_metric_alarm" "pil_alarm" {
  alarm_name          = "${var.function_name}-image-processing-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ImageProcessingErrors"
  namespace           = var.metric_namespace
  period              = 60
  statistic           = "Sum"
  threshold           = 2
  alarm_description   = "Triggers when image processing fails repeatedly"
  actions_enabled     = true
  alarm_actions       = [var.log_alerts_topic_arn]
  treat_missing_data  = "notBreaching"

  tags = merge(
    var.tags,
    {
      Name     = "${var.function_name}-pil-alarm"
      Type     = "LogBased"
      Severity = "Warning"
    }
  )
}

# Metric Filter: S3 Permission Errors
resource "aws_cloudwatch_log_metric_filter" "s3_permission_errors" {
  name           = "${var.function_name}-s3-permission-errors"
  log_group_name = var.log_group_name
  pattern        = "?\"AccessDenied\" ?\"Access Denied\" ?\"403\""

  metric_transformation {
    name          = "S3PermissionErrors"
    namespace     = var.metric_namespace
    value         = "1"
    default_value = "0"
  }
}

# Alarm: S3 Permission Errors
resource "aws_cloudwatch_metric_alarm" "s3_permission_alarm" {
  alarm_name          = "${var.function_name}-s3-permission-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "S3PermissionErrors"
  namespace           = var.metric_namespace
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Triggers when Lambda encounters S3 permission errors"
  actions_enabled     = true
  alarm_actions       = [var.log_alerts_topic_arn]
  treat_missing_data  = "notBreaching"

  tags = merge(
    var.tags,
    {
      Name     = "${var.function_name}-s3-permission-alarm"
      Type     = "LogBased"
      Severity = "Critical"
    }
  )
}

# Metric Filter: Critical Application Errors
resource "aws_cloudwatch_log_metric_filter" "critical_errors" {
  name           = "${var.function_name}-critical-errors"
  log_group_name = var.log_group_name
  pattern        = "[timestamp, request_id, level = CRITICAL*, ...]"

  metric_transformation {
    name          = "CriticalErrors"
    namespace     = var.metric_namespace
    value         = "1"
    default_value = "0"
  }
}

# Alarm: Critical Errors
resource "aws_cloudwatch_metric_alarm" "critical_alarm" {
  alarm_name          = "${var.function_name}-critical-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CriticalErrors"
  namespace           = var.metric_namespace
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Triggers when CRITICAL level errors are logged"
  actions_enabled     = true
  alarm_actions       = [var.log_alerts_topic_arn]
  treat_missing_data  = "notBreaching"

  tags = merge(
    var.tags,
    {
      Name     = "${var.function_name}-critical-alarm"
      Type     = "LogBased"
      Severity = "Critical"
    }
  )
}

# Metric Filter: Large Image Warning
resource "aws_cloudwatch_log_metric_filter" "large_images" {
  name           = "${var.function_name}-large-images"
  log_group_name = var.log_group_name
  pattern        = "\"Large image detected\""

  metric_transformation {
    name          = "LargeImageWarnings"
    namespace     = var.metric_namespace
    value         = "1"
    default_value = "0"
  }
}

# Alarm: Large Images (Performance Warning)
resource "aws_cloudwatch_metric_alarm" "large_image_alarm" {
  alarm_name          = "${var.function_name}-large-images"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "LargeImageWarnings"
  namespace           = var.metric_namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Triggers when multiple large images are processed (performance concern)"
  actions_enabled     = true
  alarm_actions       = [var.log_alerts_topic_arn]
  treat_missing_data  = "notBreaching"

  tags = merge(
    var.tags,
    {
      Name     = "${var.function_name}-large-image-alarm"
      Type     = "LogBased"
      Severity = "Info"
    }
  )
}
