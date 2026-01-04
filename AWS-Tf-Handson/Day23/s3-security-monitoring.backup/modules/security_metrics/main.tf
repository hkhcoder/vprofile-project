resource "aws_cloudwatch_log_metric_filter" "denied_requests" {
  name           = "DeniedRequestsFilter"
  pattern        = "{ $.errorCode = \"AccessDenied\" || $.errorCode = \"403\" }"
  log_group_name = var.log_group_name

  metric_transformation {
    name      = "DeniedRequests"
    namespace = "Security/S3"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "restricted_prefix" {
  name           = "RestrictedPrefixFilter"
  pattern        = "{ $.requestParameters.key = \"private/*\" }"
  log_group_name = var.log_group_name

  metric_transformation {
    name      = "RestrictedPrefixAccess"
    namespace = "Security/S3"
    value     = "1"
  }
}
