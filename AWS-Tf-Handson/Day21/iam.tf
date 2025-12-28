# IAM Policy to enforce MFA for S3 Bucket Deletion
resource "aws_iam_policy" "mfa_delete_policy" {
  name        = "${var.project_name}-MFA-Delete-Policy"
  description = "IAM policy to allow deletion of S3 buckets only with MFA"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowDeletionWithMFA"
        Effect = "Deny"
        Action = "s3:DeleteBucket"
        Resource = "*"
        Condition = {
          Bool = {
            "aws:MultiFactorAuthPresent" = "false"
          }
        }
      }
    ]
  })  
}

# IAM Policy enforce Encryption in transit for S3 Bucket
resource "aws_iam_policy" "s3_encryption_policy" {
  name        = "${var.project_name}-S3-Encryption-Policy"
  description = "IAM policy to enforce encryption in transit for S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnforceEncryptionInTransit"
        Effect = "Deny"
        Action = "s3:PutObject"
        Resource = "*"
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

# IAM Policy to require tagging of resources creation
resource "aws_iam_policy" "tagging_policy" {
  name        = "${var.project_name}-Tagging-Policy"
  description = "IAM policy to require tagging of resources creation"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid  = "EnvironmentTagging" 
        Effect = "Deny"
        Action = "s3:*"
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestTag/Environment" = ["Production", "Development"]
          }
        }
      }
    ]
  })
}

# IAM Policy to restrict EC2 instance launch without owner tags
resource "aws_iam_policy" "ec2_owner_tagging_policy" {
  name        = "${var.project_name}-EC2-Owner-Tagging-Policy"
  description = "IAM policy to restrict EC2 instance launch without owner tags"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "RequireOwnerTag"
        Effect = "Deny"
        Action = "ec2:RunInstances"
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestTag/Owner" = ["Ankur", "DevOps"]
          }
        }
      }
    ]
  })
}

# IAM user for demonstration purposes
resource "aws_iam_user" "demo_user" {
  name = "demo-User"
  path = "/governance/"

    tags = {
        Project = var.project_name
        Owner   = "Ankur"
        Environment = "Production"
    }
}


# Attach the MFA policies to the demo user
resource "aws_iam_user_policy_attachment" "mfa_delete_policy_attachment" {
  user       = aws_iam_user.demo_user.name
  policy_arn = aws_iam_policy.mfa_delete_policy.arn
}

# Attach S3 Full Access to allow the user to list buckets and test the Deny policies
resource "aws_iam_user_policy_attachment" "demo_user_s3_full_access" {
  user       = aws_iam_user.demo_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# IAM role for AWS Config to assume and evaluate compliance
resource "aws_iam_role" "config_role" {
  name = "${var.project_name}-AWS-Config-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowAWSConfigService"
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
    }
    ]
  })
}   


# Attach AWS managed policy for AWS Config role
resource "aws_iam_role_policy_attachment" "config_policy_attach" {
  role       = aws_iam_role.config_role.name
  #policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRolePolicyForConfigurationRecorder"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}



# Additional policy to write to S3 bucket for AWS Config
resource "aws_iam_policy" "config_s3_policy" {
  name        = "${var.project_name}-Config-S3-Policy"
  description = "IAM policy to allow AWS Config to write to S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {         
        Sid    = "AllowS3Write"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetBucketAcl",
          "s3:GetBucketVersioning"
        ]
        Resource = "${aws_s3_bucket.config_bucket.arn}/*"
      }
    ]
  })
}