variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "log_group_name" {
  description = "Name of the CloudWatch log group"
  type        = string
}

variable "metric_namespace" {
  description = "CloudWatch custom metrics namespace"
  type        = string
  default     = "ImageProcessor/Lambda"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "enable_dashboard" {
  description = "Enable CloudWatch dashboard creation"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
