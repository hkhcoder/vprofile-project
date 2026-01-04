variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "handler" {
  description = "Lambda function handler"
  type        = string
  default     = "lambda_function.lambda_handler"
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.12"
}

variable "timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 60
}

variable "memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 1024
}

variable "lambda_zip_path" {
  description = "Path to the Lambda function zip file"
  type        = string
}

variable "source_code_hash" {
  description = "Base64-encoded SHA256 hash of the Lambda zip"
  type        = string
}

variable "lambda_layers" {
  description = "List of Lambda layer ARNs"
  type        = list(string)
  default     = []
}

variable "upload_bucket_arn" {
  description = "ARN of the upload S3 bucket"
  type        = string
}

variable "upload_bucket_id" {
  description = "ID of the upload S3 bucket"
  type        = string
}

variable "processed_bucket_arn" {
  description = "ARN of the processed S3 bucket"
  type        = string
}

variable "processed_bucket_id" {
  description = "ID of the processed S3 bucket"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "log_level" {
  description = "Log level for Lambda function (DEBUG, INFO, WARNING, ERROR)"
  type        = string
  default     = "INFO"
}

variable "environment_variables" {
  description = "Additional environment variables for Lambda"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
