resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# 1. The Bucket we want to monitor
resource "aws_s3_bucket" "monitored_bucket" {
  bucket        = "${var.monitored_bucket_name}-${random_id.bucket_suffix.hex}"
  force_destroy = true
}

# 2. The Bucket where CloudTrail stores logs (required)
resource "aws_s3_bucket" "trail_logs_bucket" {
  bucket        = "${var.monitored_bucket_name}-trail-logs-${random_id.bucket_suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "trail_logs_policy" {
  bucket = aws_s3_bucket.trail_logs_bucket.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "${aws_s3_bucket.trail_logs_bucket.arn}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.trail_logs_bucket.arn}/prefix/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}

data "aws_caller_identity" "current" {}

# 3. CloudWatch Log Group
resource "aws_cloudwatch_log_group" "s3_access_logs" {
  name              = "/aws/cloudtrail/${var.monitored_bucket_name}"
  retention_in_days = 7
}

# 4. IAM Role for CloudTrail to write to CloudWatch Logs
resource "aws_iam_role" "cloudtrail_cw_role" {
  name = "cloudtrail-to-cw-logs-${random_id.bucket_suffix.hex}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudtrail_cw_policy" {
  name = "cloudtrail-cw-policy"
  role = aws_iam_role.cloudtrail_cw_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AWSCloudTrailCreateLogStream",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "${aws_cloudwatch_log_group.s3_access_logs.arn}:*"
    }
  ]
}
EOF
}

# 5. CloudTrail
resource "aws_cloudtrail" "s3_data_events_trail" {
  name                          = "s3-data-events-trail-${random_id.bucket_suffix.hex}"
  s3_bucket_name                = aws_s3_bucket.trail_logs_bucket.id
  s3_key_prefix                 = "prefix"
  include_global_service_events = false

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.s3_access_logs.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_cw_role.arn

  event_selector {
    read_write_type           = "All"
    include_management_events = false

    data_resource {
      type   = "AWS::S3::Object"
      values = ["${aws_s3_bucket.monitored_bucket.arn}/"]
    }
  }

  depends_on = [aws_s3_bucket_policy.trail_logs_policy]
}

# 6. Upload a test file to the restricted prefix (managed by Terraform)
resource "aws_s3_object" "restricted_file" {
  bucket  = aws_s3_bucket.monitored_bucket.id
  key     = "private/secret-file.txt"
  content = "This is a secret file. Accessing it might trigger an alarm."
}
