variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "security_alert_email" {
  description = "Email address to receive security alerts"
  type        = string
}

variable "monitored_bucket_name" {
  description = "Base name for the bucket to monitor"
  type        = string
  default     = "my-secure-bucket"
}
