variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "critical_alerts_topic_arn" {
  description = "ARN of the SNS topic for critical alerts"
  type        = string
}

variable "performance_alerts_topic_arn" {
  description = "ARN of the SNS topic for performance alerts"
  type        = string
}

variable "metric_namespace" {
  description = "CloudWatch custom metrics namespace"
  type        = string
  default     = "ImageProcessor/Lambda"
}

variable "alarm_period" {
  description = "Period for alarm evaluation in seconds"
  type        = number
  default     = 60
}

# Error Alarm Configuration
variable "error_threshold" {
  description = "Number of errors to trigger alarm"
  type        = number
  default     = 3
}

variable "error_evaluation_periods" {
  description = "Number of periods to evaluate for error alarm"
  type        = number
  default     = 1
}

# Duration Alarm Configuration
variable "duration_threshold_ms" {
  description = "Duration threshold in milliseconds"
  type        = number
  default     = 45000 # 45 seconds (75% of 60s timeout)
}

variable "duration_evaluation_periods" {
  description = "Number of periods to evaluate for duration alarm"
  type        = number
  default     = 2
}

# Throttle Alarm Configuration
variable "throttle_threshold" {
  description = "Number of throttles to trigger alarm"
  type        = number
  default     = 5
}

variable "throttle_evaluation_periods" {
  description = "Number of periods to evaluate for throttle alarm"
  type        = number
  default     = 1
}

# Concurrent Executions Configuration
variable "concurrent_executions_threshold" {
  description = "Concurrent executions threshold"
  type        = number
  default     = 50
}

# Log Error Threshold
variable "log_error_threshold" {
  description = "Number of log errors to trigger alarm"
  type        = number
  default     = 1
}

# Success Rate Configuration
variable "min_success_threshold" {
  description = "Minimum successful processes expected"
  type        = number
  default     = 1
}

# Optional Alarms
variable "enable_no_invocation_alarm" {
  description = "Enable alarm for no invocations"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
