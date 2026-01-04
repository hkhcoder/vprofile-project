# ============================================================================
# AWS LAMBDA IMAGE PROCESSOR WITH COMPREHENSIVE MONITORING
# Modular Terraform Configuration
# ============================================================================

# Random suffix for unique resource names
resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  bucket_prefix         = "${var.project_name}-${var.environment}"
  upload_bucket_name    = "${local.bucket_prefix}-upload-${random_id.suffix.hex}"
  processed_bucket_name = "${local.bucket_prefix}-processed-${random_id.suffix.hex}"
  lambda_function_name  = "${var.project_name}-${var.environment}-processor"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    CreatedDate = timestamp()
  }
}

# ============================================================================
# LAMBDA LAYER (Pillow)
# ============================================================================

resource "aws_lambda_layer_version" "pillow_layer" {
  filename            = "${path.module}/pillow_layer.zip"
  layer_name          = "${var.project_name}-pillow-layer"
  compatible_runtimes = ["python3.12"]
  description         = "Pillow library for image processing"
}

# Data source for Lambda function zip
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

# ============================================================================
# MODULE: SNS NOTIFICATIONS
# Creates SNS topics and subscriptions for alerts
# ============================================================================

module "sns_notifications" {
  source = "./modules/sns_notifications"

  project_name            = var.project_name
  environment             = var.environment
  critical_alert_email    = var.alert_email
  performance_alert_email = var.alert_email
  log_alert_email         = var.alert_email
  critical_alert_sms      = var.alert_sms

  tags = local.common_tags
}

# ============================================================================
# MODULE: S3 BUCKETS (Created First)
# Creates upload and processed buckets with security configurations
# ============================================================================

module "s3_buckets" {
  source = "./modules/s3_buckets"

  upload_bucket_name    = local.upload_bucket_name
  processed_bucket_name = local.processed_bucket_name
  environment           = var.environment
  enable_versioning     = var.enable_s3_versioning

  tags = local.common_tags
}

# ============================================================================
# MODULE: LAMBDA FUNCTION
# Creates Lambda function with IAM roles and CloudWatch logs
# ============================================================================

module "lambda_function" {
  source = "./modules/lambda_function"

  function_name    = local.lambda_function_name
  handler          = "lambda_function.lambda_handler"
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size
  lambda_zip_path  = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  lambda_layers    = [aws_lambda_layer_version.pillow_layer.arn]

  # Use actual bucket ARNs from S3 module
  upload_bucket_arn    = module.s3_buckets.upload_bucket_arn
  upload_bucket_id     = module.s3_buckets.upload_bucket_id
  processed_bucket_arn = module.s3_buckets.processed_bucket_arn
  processed_bucket_id  = module.s3_buckets.processed_bucket_id

  aws_region         = var.aws_region
  log_retention_days = var.log_retention_days
  log_level          = var.log_level

  tags = local.common_tags
}

# Lambda permission to be invoked by S3
resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = module.s3_buckets.upload_bucket_arn
}

# S3 bucket notification to trigger Lambda
resource "aws_s3_bucket_notification" "upload_trigger" {
  bucket = module.s3_buckets.upload_bucket_id

  lambda_function {
    lambda_function_arn = module.lambda_function.function_arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3_invoke]
}


# ============================================================================
# MODULE: CLOUDWATCH METRICS
# Creates custom metrics, metric filters, and dashboard
# ============================================================================

module "cloudwatch_metrics" {
  source = "./modules/cloudwatch_metrics"

  function_name    = module.lambda_function.function_name
  log_group_name   = module.lambda_function.log_group_name
  metric_namespace = var.metric_namespace
  aws_region       = var.aws_region
  enable_dashboard = var.enable_cloudwatch_dashboard

  tags = local.common_tags
}

# ============================================================================
# MODULE: CLOUDWATCH ALARMS
# Creates CloudWatch alarms for Lambda monitoring
# ============================================================================

module "cloudwatch_alarms" {
  source = "./modules/cloudwatch_alarms"

  function_name                = module.lambda_function.function_name
  critical_alerts_topic_arn    = module.sns_notifications.critical_alerts_topic_arn
  performance_alerts_topic_arn = module.sns_notifications.performance_alerts_topic_arn
  metric_namespace             = var.metric_namespace

  # Alarm thresholds
  error_threshold                 = var.error_threshold
  duration_threshold_ms           = var.duration_threshold_ms
  throttle_threshold              = var.throttle_threshold
  concurrent_executions_threshold = var.concurrent_executions_threshold
  log_error_threshold             = var.log_error_threshold
  enable_no_invocation_alarm      = var.enable_no_invocation_alarm

  tags = local.common_tags
}

# ============================================================================
# MODULE: LOG ALERTS
# Creates log-based metric filters and alarms for specific error patterns
# ============================================================================

module "log_alerts" {
  source = "./modules/log_alerts"

  function_name        = module.lambda_function.function_name
  log_group_name       = module.lambda_function.log_group_name
  log_alerts_topic_arn = module.sns_notifications.log_alerts_topic_arn
  metric_namespace     = var.metric_namespace

  tags = local.common_tags
}
