resource "random_id" "name" {
  byte_length = 4
}

locals {
  bucket_prefix        = "${var.project_name}-${var.environment}"
  upload_bucket_name   = "${local.bucket_prefix}-${random_id.name.hex}"
  processed_bucket_name = "${local.bucket_prefix}-processed-${random_id.name.hex}"
  lambda_function_name = "${var.project_name}-${var.environment}-processor"
}

##################################### 
# S3 Buckets 
#####################################

## Upload Bucket (SOURCE BUCKET)
resource "aws_s3_bucket" "upload_bucket" {
  bucket = local.upload_bucket_name
}

resource "aws_s3_bucket_versioning" "upload_bucket_versioning" {
  bucket = aws_s3_bucket.upload_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "upload_bucket_encryption" {
  bucket = aws_s3_bucket.upload_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "upload_bucket_public_access_block" {
  bucket = aws_s3_bucket.upload_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


## Processed Bucket (DESTINATION BUCKET)
resource "aws_s3_bucket" "processed_bucket" {
  bucket = local.processed_bucket_name
}

resource "aws_s3_bucket_versioning" "processed_bucket_versioning" {
  bucket = aws_s3_bucket.processed_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "processed_bucket_encryption" {
  bucket = aws_s3_bucket.processed_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "processed_bucket_public_access_block" {

  bucket = aws_s3_bucket.processed_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


###################################### 
# S3 Bucket Notification for Lambda Function
######################################
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.upload_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_function.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

###################################### 
# IAM Role and Policy for Lambda Function
######################################
resource "aws_iam_role" "lambda_exec_role" {
  name = "${local.lambda_function_name}-exec-role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_exec_policy" {
  name = "${local.lambda_function_name}-exec-policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:${var.region}:*:*:*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:GetObject",
          "s3:GetObjectVersion",
        ],
        "Resource": "{aws_s3_bucket.upload_bucket.arn}/*"
      },    
      {
        "Effect": "Allow",
        "Action": [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        "Resource": "{aws_s3_bucket.processed_bucket.arn}/*"
      }
    ]
  })
}


#################################### 
# Lambda Layer for dependencies
####################################
resource "aws_lambda_layer_version" "lambda_layer" {
  filename          = "lambda_layer_payload.zip"
  layer_name        = "${local.lambda_function_name}-layer"
  compatible_runtimes = ["python3.9"]
  description = "Lambda layer for image processing dependencies"
}

###################################### 
# Lambda Function
######################################   
data "archive_file" "lambda_function_zip" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function.zip"
}

   
resource "aws_lambda_function" "lambda_function" {
  
  filename      = "lambda_function.zip"
  function_name = local.lambda_function_name
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "index.handler"
  runtime       = "python3.9"

  layers = [aws_lambda_layer_version.lambda_layer.arn]

  environment {
    variables = {
      PROCESSED_BUCKET = aws_s3_bucket.processed_bucket.bucket
    }
  }
}

resource "aws_lambda_permission" "allow_bucket" {
  function_name = aws_lambda_function.lambda_function.function_name
  action        = "lambda:InvokeFunction"
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.upload_bucket.arn
}       
