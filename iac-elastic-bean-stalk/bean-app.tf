resource "aws_elastic_beanstalk_application" "vprofile-prod" {
  name        = "vprofile-prod"
  description = "Beanstalk App for vprofile project by Terraform"
}