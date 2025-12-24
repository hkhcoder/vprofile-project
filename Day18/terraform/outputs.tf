output "application_name" {
  description = "Name of the Elastic Beanstalk application"
  value       = aws_elastic_beanstalk_application.app.name
}

output "blue_environment_name" {
  description = "Name of the Blue (Production) environment"
  value       = aws_elastic_beanstalk_environment.blue.name
}

output "blue_environment_url" {
  description = "URL of the Blue (Production) environment"
  value       = "http://${aws_elastic_beanstalk_environment.blue.cname}"
}

output "blue_environment_cname" {
  description = "CNAME of the Blue environment"
  value       = aws_elastic_beanstalk_environment.blue.cname
}

output "green_environment_name" {
  description = "Name of the Green (Staging) environment"
  value       = aws_elastic_beanstalk_environment.green.name
}

output "green_environment_url" {
  description = "URL of the Green (Staging) environment"
  value       = "http://${aws_elastic_beanstalk_environment.green.cname}"
}

output "green_environment_cname" {
  description = "CNAME of the Green environment"
  value       = aws_elastic_beanstalk_environment.green.cname
}

output "s3_bucket" {
  description = "S3 bucket for application versions"
  value       = aws_s3_bucket.app_versions.id
}

output "swap_command" {
  description = "AWS CLI command to swap environment CNAMEs"
  value       = <<-EOT
    aws elasticbeanstalk swap-environment-cnames \
      --source-environment-name ${aws_elastic_beanstalk_environment.blue.name} \
      --destination-environment-name ${aws_elastic_beanstalk_environment.green.name} \
      --region ${var.aws_region}
  EOT
}

output "instructions" {
  description = "Step-by-step instructions for the blue-green deployment"
  value       = <<-EOT
    
    ========================================
    Blue-Green Deployment Demo Instructions
    ========================================
    
    1. VERIFY BLUE ENVIRONMENT (Production - v1.0):
       Visit: ${aws_elastic_beanstalk_environment.blue.cname}
       Expected: "Welcome to Version 1.0 - Blue Environment"
    
    2. VERIFY GREEN ENVIRONMENT (Staging - v2.0):
       Visit: ${aws_elastic_beanstalk_environment.green.cname}
       Expected: "Welcome to Version 2.0 - Green Environment"
    
    3. PERFORM THE SWAP:
       Run this AWS CLI command to swap the CNAMEs:
       
       aws elasticbeanstalk swap-environment-cnames \
         --source-environment-name ${aws_elastic_beanstalk_environment.blue.name} \
         --destination-environment-name ${aws_elastic_beanstalk_environment.green.name} \
         --region ${var.aws_region}
    
    4. VERIFY THE SWAP:
       After the swap completes (takes ~1-2 minutes):
       
       Blue URL now shows v2.0:
       Visit: ${aws_elastic_beanstalk_environment.blue.cname}
       Expected: "Welcome to Version 2.0 - Green Environment"
       
       Green URL now shows v1.0:
       Visit: ${aws_elastic_beanstalk_environment.green.cname}
       Expected: "Welcome to Version 1.0 - Blue Environment"
    
    5. ROLLBACK (if needed):
       Simply swap again using the same command to revert!
    
    ========================================
  EOT
}