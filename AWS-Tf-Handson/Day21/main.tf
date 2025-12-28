# Main Terraform configuration file

data "aws_caller_identity" "current" {}

# S3 Bucket to store Config logs
resource "aws_s3_bucket" "config_bucket" {
  bucket = "${var.project_name}-bucket-${random_string.bucket_suffix.result}" # Replace with your desired bucket name
  #acl    = "private"

  tags = {
    Name        = "${var.project_name}-Config-Bucket"
    Manageby    = "Ankur"
    Environment = "Production"
    purposes    = "AWS Config logs storage"
}
}

# Generate a random suffix for the bucket name
resource "random_string" "bucket_suffix" {
  length  = 4
  upper   = false
  special = false
}

# Enable versioning on the S3 bucket
resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.config_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption on the S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "config_bucket" {
  bucket = aws_s3_bucket.config_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
    }
  }
}


# Block public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.config_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  skip_destroy            = true
}


# S3 Bucket Policy to allow AWS Config to write to the bucket
resource "aws_s3_bucket_policy" "config_bucket_policy" {
  bucket = aws_s3_bucket.config_bucket.id
  
  policy = jsonencode({
    "Version":"2012-10-17",		 	 	 
    "Statement": [
    {
      "Sid": "AWSConfigBucketPermissionsCheck",
      "Effect": "Allow",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "${aws_s3_bucket.config_bucket.arn}",
      "Condition": { 
        "StringEquals": {
          "AWS:SourceAccount": "${data.aws_caller_identity.current.account_id}"
        }
      }
    },
    {
      "Sid": "AWSConfigBucketExistenceCheck",
      "Effect": "Allow",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Action": "s3:ListBucket",
      "Resource": "${aws_s3_bucket.config_bucket.arn}",
      "Condition": { 
        "StringEquals": {
          "AWS:SourceAccount": "${data.aws_caller_identity.current.account_id}"
        }
      }
    },
    {
      "Sid": "AWSConfigBucketDelivery",
      "Effect": "Allow",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.config_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/Config/*",
      "Condition": { 
        "StringEquals": { 
          "s3:x-amz-acl": "bucket-owner-full-control",
          "AWS:SourceAccount": "${data.aws_caller_identity.current.account_id}"
        }
      }
    },
    {
      "Sid": "DenyInsecureTransport",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": "${aws_s3_bucket.config_bucket.arn}/*",
      "Condition": { 
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
})
}
