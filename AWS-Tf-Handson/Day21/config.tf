#################################################
# AWS Config recorder and delivery channel setup
#################################################

resource "aws_config_configuration_recorder" "main" {
  name     = "${var.project_name}-config-recorder"
  role_arn = aws_iam_role.config_role.arn
}

resource "aws_config_delivery_channel" "main" {
  name           = "${var.project_name}-config-delivery-channel"
  s3_bucket_name = aws_s3_bucket.config_bucket.bucket
  depends_on     = [aws_config_configuration_recorder.main]
}

resource "aws_config_configuration_recorder_status" "main" {
  name       = aws_config_configuration_recorder.main.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.main]
}


###############################################
# AWS Config Rules - Compliance Rules
###############################################
resource "aws_config_config_rule" "s3_bucket_versioning_enabled" {
  name = "s3-bucket-versioning-enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_VERSIONING_ENABLED"
  }
    depends_on = [ aws_config_configuration_recorder.main ]
}

resource "aws_config_config_rule" "aws_s3_bucket_public_access_block" {
  name = "aws-s3-bucket-public-access-block"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_ACCESS_BLOCK"
  }
  depends_on = [ aws_config_configuration_recorder.main ]
}


resource "aws_config_config_rule" "s3_bucket_server_side_encryption_configuration" {
  name = "s3-bucket-server-side-encryption-configuration"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_CONFIGURATION"
  }
  depends_on = [ aws_config_configuration_recorder.main ]
}   


resource "aws_config_config_rule" "ebs_encrypted_volumes" {
  name = "ebs-encrypted-volumes"

  source {
    owner             = "AWS"
    source_identifier = "EBS_ENCRYPTED_VOLUMES"
  } 
  depends_on = [ aws_config_configuration_recorder.main ]
}

resource "aws_config_config_rule" "ec2_instance_no_public_ip" {
  name = "ec2-instance-no-public-ip"

  source {
    owner             = "AWS"
    source_identifier = "EC2_INSTANCE_NO_PUBLIC_IP"
  }
    depends_on = [ aws_config_configuration_recorder.main ]
}

resource "aws_config_config_rule" "iam_password_policy" {
  name = "iam-password-policy"

  source {
    owner             = "AWS"
    source_identifier = "IAM_PASSWORD_POLICY"
  }
    depends_on = [ aws_config_configuration_recorder.main ]
}

resource "aws_config_config_rule" "aws_iam_mfa_enabled" {
  name = "aws-iam-mfa-enabled"

  source {
    owner             = "AWS"
    source_identifier = "AWS_IAM_MFA_ENABLED"
  }  
    depends_on = [ aws_config_configuration_recorder.main ]
}
