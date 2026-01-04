# ============================================================================
# SNS NOTIFICATIONS MODULE
# Creates SNS topics and subscriptions for different alert types
# ============================================================================

# SNS Topic for Critical Alerts (Errors, Failures)
resource "aws_sns_topic" "critical_alerts" {
  name         = "${var.project_name}-${var.environment}-critical-alerts"
  display_name = "Critical Lambda Alerts - ${var.project_name}"

  tags = merge(
    var.tags,
    {
      Name      = "${var.project_name}-critical-alerts"
      AlertType = "Critical"
    }
  )
}

# SNS Topic for Performance Alerts (Duration, Memory)
resource "aws_sns_topic" "performance_alerts" {
  name         = "${var.project_name}-${var.environment}-performance-alerts"
  display_name = "Performance Alerts - ${var.project_name}"

  tags = merge(
    var.tags,
    {
      Name      = "${var.project_name}-performance-alerts"
      AlertType = "Performance"
    }
  )
}

# SNS Topic for Log-based Alerts
resource "aws_sns_topic" "log_alerts" {
  name         = "${var.project_name}-${var.environment}-log-alerts"
  display_name = "Log Pattern Alerts - ${var.project_name}"

  tags = merge(
    var.tags,
    {
      Name      = "${var.project_name}-log-alerts"
      AlertType = "Logs"
    }
  )
}

# Email subscription for Critical Alerts
resource "aws_sns_topic_subscription" "critical_email" {
  count     = var.critical_alert_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.critical_alerts.arn
  protocol  = "email"
  endpoint  = var.critical_alert_email
}

# Email subscription for Performance Alerts
resource "aws_sns_topic_subscription" "performance_email" {
  count     = var.performance_alert_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.performance_alerts.arn
  protocol  = "email"
  endpoint  = var.performance_alert_email
}

# Email subscription for Log Alerts
resource "aws_sns_topic_subscription" "log_email" {
  count     = var.log_alert_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.log_alerts.arn
  protocol  = "email"
  endpoint  = var.log_alert_email
}

# Optional SMS subscription for Critical Alerts
resource "aws_sns_topic_subscription" "critical_sms" {
  count     = var.critical_alert_sms != "" ? 1 : 0
  topic_arn = aws_sns_topic.critical_alerts.arn
  protocol  = "sms"
  endpoint  = var.critical_alert_sms
}

# SNS Topic Policy (allows CloudWatch to publish)
resource "aws_sns_topic_policy" "critical_alerts_policy" {
  arn = aws_sns_topic.critical_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"  # 1. Allow access
        Principal = {
          Service = "cloudwatch.amazonaws.com"  # 2. WHO: The CloudWatch Service
        }
        Action = [
          "SNS:Publish"  # 3. WHAT: Permission to publish messages.
        ]
        Resource = aws_sns_topic.critical_alerts.arn # 4. TO WHICH RESOURCE: This SNS Topic
      }
    ]
  })
}

resource "aws_sns_topic_policy" "performance_alerts_policy" {
  arn = aws_sns_topic.performance_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action = [
          "SNS:Publish"
        ]
        Resource = aws_sns_topic.performance_alerts.arn
      }
    ]
  })
}

resource "aws_sns_topic_policy" "log_alerts_policy" {
  arn = aws_sns_topic.log_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action = [
          "SNS:Publish"
        ]
        Resource = aws_sns_topic.log_alerts.arn
      }
    ]
  })
}
