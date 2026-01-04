# ============================================================================
# S3 BUCKETS MODULE
# Creates upload (source) and processed (destination) buckets with security
# ============================================================================

# S3 Bucket for uploading original images (SOURCE)
resource "aws_s3_bucket" "upload_bucket" {
  bucket = var.upload_bucket_name

  tags = merge(
    var.tags,
    {
      Name        = var.upload_bucket_name
      Purpose     = "Image Upload Source"
      Environment = var.environment
    }
  )
}

resource "aws_s3_bucket_versioning" "upload_bucket" {
  bucket = aws_s3_bucket.upload_bucket.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "upload_bucket" {
  bucket = aws_s3_bucket.upload_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "upload_bucket" {
  bucket = aws_s3_bucket.upload_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket for processed images (DESTINATION)
resource "aws_s3_bucket" "processed_bucket" {
  bucket = var.processed_bucket_name

  tags = merge(
    var.tags,
    {
      Name        = var.processed_bucket_name
      Purpose     = "Processed Images Destination"
      Environment = var.environment
    }
  )
}

resource "aws_s3_bucket_versioning" "processed_bucket" {
  bucket = aws_s3_bucket.processed_bucket.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "processed_bucket" {
  bucket = aws_s3_bucket.processed_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "processed_bucket" {
  bucket = aws_s3_bucket.processed_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
