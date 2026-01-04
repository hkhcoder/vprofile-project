variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "log_group_name" {
  description = "Name of the CloudWatch log group"
  type        = string
}

variable "log_alerts_topic_arn" {
  description = "ARN of the SNS topic for log-based alerts"
  type        = string
}

variable "metric_namespace" {
  description = "CloudWatch custom metrics namespace"
  type        = string
  default     = "ImageProcessor/Lambda"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
