
# Application Version 2.0 (Green Environment - Staging)
resource "aws_s3_object" "app_v2" {
  bucket = aws_s3_bucket.app_versions.id
  key    = "app-v2.zip"
  source = "${path.module}/app-v2/app-v2.zip"
  etag   = filemd5("${path.module}/app-v2/app-v2.zip")

  tags = var.tags
}

resource "aws_elastic_beanstalk_application_version" "v2" {
  name        = "${var.app_name}-v2"
  application = aws_elastic_beanstalk_application.app.name
  description = "Application Version 2.0 - New Feature Release"
  bucket      = aws_s3_bucket.app_versions.id
  key         = aws_s3_object.app_v2.id

  tags = var.tags
}

# Green Environment (Staging/Pre-production)
resource "aws_elastic_beanstalk_environment" "green" {
  name                = "${var.app_name}-green"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = var.solution_stack_name
  tier                = "WebServer"
  version_label       = aws_elastic_beanstalk_application_version.v2.name

  # IAM Settings
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.eb_ec2_profile.name
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = aws_iam_role.eb_service_role.name
  }

  # Instance Settings
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = var.instance_type
  }

  # Environment Type (Load Balanced)
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "LoadBalanced"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }

  # Auto Scaling Settings
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "1"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "2"
  }

  # Health Reporting
  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = "enhanced"
  }

  # Platform Settings
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "HealthCheckPath"
    value     = "/"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Port"
    value     = "8080"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Protocol"
    value     = "HTTP"
  }

  # Environment Variables
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "ENVIRONMENT"
    value     = "green"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "VERSION"
    value     = "2.0"
  }

  # Deployment Policy
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "DeploymentPolicy"
    value     = "Rolling"
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "BatchSizeType"
    value     = "Percentage"
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "BatchSize"
    value     = "50"
  }

  # Managed Updates
  setting {
    namespace = "aws:elasticbeanstalk:managedactions"
    name      = "ManagedActionsEnabled"
    value     = "false"
  }

  tags = merge(
    var.tags,
    {
      Environment = "green"
      Role        = "staging"
    }
  )
}
