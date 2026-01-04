# ============================================================================
# CLOUDWATCH METRICS MODULE
# Creates custom metrics, metric filters, and CloudWatch dashboard
# Here is the documentation for reference:
# https://docs.aws.amazon.com/lambda/latest/dg/monitoring-metrics-types.html#deployment-metrics
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_dashboard
# ============================================================================

# Metric Filter: Lambda Errors
resource "aws_cloudwatch_log_metric_filter" "lambda_errors" {
  name           = "${var.function_name}-error-count"
  log_group_name = var.log_group_name
  pattern        = "[timestamp, request_id, level = ERROR*, ...]"

  metric_transformation {
    name          = "LambdaErrors"
    namespace     = var.metric_namespace
    value         = "1"
    default_value = "0"
  }
}

# Metric Filter: Image Processing Time
resource "aws_cloudwatch_log_metric_filter" "processing_time" {
  name           = "${var.function_name}-processing-time"
  log_group_name = var.log_group_name
  pattern        = "[timestamp, request_id, level, message, processing_time_key = \"processing_time:\", processing_time, ...]"

  metric_transformation {
    name          = "ImageProcessingTime"
    namespace     = var.metric_namespace
    value         = "$processing_time"
    unit          = "Milliseconds"
    default_value = "0"
  }
}

# Metric Filter: Successful Processes
resource "aws_cloudwatch_log_metric_filter" "successful_processes" {
  name           = "${var.function_name}-success-count"
  log_group_name = var.log_group_name
  pattern        = "\"Successfully processed\""

  metric_transformation {
    name          = "SuccessfulProcesses"
    namespace     = var.metric_namespace
    value         = "1"
    default_value = "0"
  }
}

# Metric Filter: Image Size
resource "aws_cloudwatch_log_metric_filter" "image_size" {
  name           = "${var.function_name}-image-size"
  log_group_name = var.log_group_name
  pattern        = "[timestamp, request_id, level, message, size_key = \"image_size:\", image_size, ...]"

  metric_transformation {
    name          = "ImageSizeBytes"
    namespace     = var.metric_namespace
    value         = "$image_size"
    unit          = "Bytes"
    default_value = "0"
  }
}

# Metric Filter: S3 Access Denied
resource "aws_cloudwatch_log_metric_filter" "s3_access_denied" {
  name           = "${var.function_name}-s3-denied"
  log_group_name = var.log_group_name
  pattern        = "AccessDenied"

  metric_transformation {
    name          = "S3AccessDenied"
    namespace     = var.metric_namespace
    value         = "1"
    default_value = "0"
  }
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "lambda_monitoring" {
  count          = var.enable_dashboard ? 1 : 0
  dashboard_name = "${var.function_name}-monitoring"

  dashboard_body = jsonencode({
    widgets = [
      {
        # Widget for Lambda Invocations and Errors
        type = "metric"
        properties = {
          metrics = [
            // 1. Namespace, 2. Metric Name, 3. Options
            ["AWS/Lambda", "Invocations", { stat = "Sum", label = "Total Invocations" }],
            [".", "Errors", { stat = "Sum", label = "Errors" }],
            [".", "Throttles", { stat = "Sum", label = "Throttles" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Lambda Invocations & Errors"
          period  = 300
          dimensions = {
            FunctionName = var.function_name
          }
        }
        width  = 12
        height = 6
        x      = 0
        y      = 0
      },
      {
        # Widget for Lambda Duration
        type = "metric"
        properties = {
          metrics = [
            // 1. Namespace, 2. Metric Name, 3. Options
            ["AWS/Lambda", "Duration", { stat = "Average", label = "Avg Duration" }],
            ["...", { stat = "Maximum", label = "Max Duration" }],
            ["...", { stat = "p99", label = "P99 Duration" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Lambda Duration (ms)"
          period  = 300
          yAxis = {
            left = {
              min = 0
            }
          }
          dimensions = {
            FunctionName = var.function_name
          }
        }
        width  = 12
        height = 6
        x      = 12
        y      = 0
      },
      {
        # Widget for Concurrent Executions
        type = "metric"
        properties = {
          metrics = [
            // 1. Namespace, 2. Metric Name, 3. Options
            ["AWS/Lambda", "ConcurrentExecutions", { stat = "Maximum", label = "Concurrent Executions" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Concurrent Executions"
          period  = 300
          dimensions = {
            FunctionName = var.function_name
          }
        }
        width  = 12
        height = 6
        x      = 0
        y      = 6
      },
      {
        # Widget for Custom Metrics: Errors vs Success
        type = "metric"
        properties = {
          metrics = [
            // 1. Namespace, 2. Metric Name, 3. Options
            [var.metric_namespace, "LambdaErrors", { stat = "Sum", label = "Log Errors" }],
            [".", "SuccessfulProcesses", { stat = "Sum", label = "Successful" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Custom Metrics: Errors vs Success"
          period  = 300
        }
        width  = 12
        height = 6
        x      = 12
        y      = 6
      },
      {
        # Widget for Image Processing Time
        type = "metric"
        properties = {
          metrics = [
            // 1. Namespace, 2. Metric Name, 3. Options
            [var.metric_namespace, "ImageProcessingTime", { stat = "Average", label = "Avg Processing Time" }],
            ["...", { stat = "Maximum", label = "Max Processing Time" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Image Processing Time (ms)"
          period  = 300
        }
        width  = 12
        height = 6
        x      = 0
        y      = 12
      },
      {
        # Widget for Image Size
        type = "metric"
        properties = {
          metrics = [
            // 1. Namespace, 2. Metric Name, 3. Options
            [var.metric_namespace, "ImageSizeBytes", { stat = "Average", label = "Avg Image Size" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Image Size (Bytes)"
          period  = 300
        }
        width  = 12
        height = 6
        x      = 12
        y      = 12
      },
      {
        # Widget for Recent Errors from Log Group
        type = "log"
        properties = {
          query  = "SOURCE '${var.log_group_name}'\n| fields @timestamp, @message\n| filter @message like /ERROR/\n| sort @timestamp desc\n| limit 20"
          region = var.aws_region
          title  = "Recent Errors"
        }
        width  = 24
        height = 6
        x      = 0
        y      = 18
      }
    ]
  })
}
