variable "upload_bucket_name" {
  description = "Name of the S3 bucket for uploading images"
  type        = string
}

variable "processed_bucket_name" {
  description = "Name of the S3 bucket for processed images"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "enable_versioning" {
  description = "Enable versioning on S3 buckets"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
