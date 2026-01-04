# ============================================================================
# GENERAL CONFIGURATION
# ============================================================================

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "image-processor"
}

# ============================================================================
# LAMBDA CONFIGURATION
# ============================================================================

variable "lambda_runtime" {
  description = "Lambda runtime version"
  type        = string
  default     = "python3.12"
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 60
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 1024
}

variable "log_level" {
  description = "Lambda function log level (DEBUG, INFO, WARNING, ERROR)"
  type        = string
  default     = "INFO"
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention period in days"
  type        = number
  default     = 7
}

# ============================================================================
# S3 CONFIGURATION
# ============================================================================

variable "enable_s3_versioning" {
  description = "Enable versioning on S3 buckets"
  type        = bool
  default     = true
}

# ============================================================================
# MONITORING & ALERTING CONFIGURATION
# ============================================================================

variable "alert_email" {
  description = "Email address for receiving CloudWatch alerts"
  type        = string
  default     = ""
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.alert_email)) || var.alert_email == ""
    error_message = "Must be a valid email address or empty string."
  }
}

variable "alert_sms" {
  description = "Phone number for critical SMS alerts (format: +1234567890)"
  type        = string
  default     = ""
}

variable "metric_namespace" {
  description = "CloudWatch custom metrics namespace"
  type        = string
  default     = "ImageProcessor/Lambda"
}

variable "enable_cloudwatch_dashboard" {
  description = "Enable CloudWatch dashboard creation"
  type        = bool
  default     = true
}

# ============================================================================
# ALARM THRESHOLDS
# ============================================================================

variable "error_threshold" {
  description = "Number of Lambda errors to trigger critical alarm"
  type        = number
  default     = 3
}

variable "duration_threshold_ms" {
  description = "Lambda duration threshold in milliseconds (75% of timeout recommended)"
  type        = number
  default     = 45000
}

variable "throttle_threshold" {
  description = "Number of throttles to trigger alarm"
  type        = number
  default     = 5
}

variable "concurrent_executions_threshold" {
  description = "Concurrent executions threshold for performance warning"
  type        = number
  default     = 50
}

variable "log_error_threshold" {
  description = "Number of log errors to trigger alarm"
  type        = number
  default     = 1
}

variable "enable_no_invocation_alarm" {
  description = "Enable alarm for detecting when Lambda has no invocations"
  type        = bool
  default     = false
}
