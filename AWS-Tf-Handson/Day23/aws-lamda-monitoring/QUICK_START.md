# Quick Deployment Guide

## Prerequisites Check
```bash
# Verify AWS CLI
aws sts get-caller-identity

# Verify Terraform
terraform version

# Verify Docker
docker --version
```

## Step 1: Build Lambda Layer (One-time)
```bash
cd scripts
./build_layer_docker.sh
cd ../terraform
```

## Step 2: Configure
```bash
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

**Required:** Change `alert_email` to your email address!

## Step 3: Deploy
```bash
terraform init
terraform plan
terraform apply
```

## Step 4: Confirm SNS
Check your email and confirm 3 subscription links.

## Step 5: Test
```bash
# Get bucket name
BUCKET=$(terraform output -raw upload_bucket_name)

# Upload image
aws s3 cp path/to/image.jpg s3://$BUCKET/

# Watch logs
aws logs tail $(terraform output -raw lambda_log_group_name) --follow
```

## Step 6: View Dashboard
```bash
terraform output cloudwatch_dashboard_url
# Open URL in browser
```

## Cleanup
```bash
terraform destroy
```

## Troubleshooting

### Lambda not triggering?
```bash
# Check S3 notification
aws s3api get-bucket-notification-configuration --bucket $BUCKET
```

### No email alerts?
- Check spam folder
- Verify SNS subscription confirmed
- AWS Console → SNS → Subscriptions

### Check alarms
```bash
aws cloudwatch describe-alarms --alarm-names image-processor-dev-processor-high-error-rate
```

## Useful Commands

```bash
# List all alarms
aws cloudwatch describe-alarms --query 'MetricAlarms[].AlarmName'

# View recent logs
aws logs tail /aws/lambda/image-processor-dev-processor --since 1h

# Test alarm
aws cloudwatch set-alarm-state \
  --alarm-name image-processor-dev-processor-high-error-rate \
  --state-value ALARM \
  --state-reason "Testing"

# List S3 objects
aws s3 ls s3://$(terraform output -raw processed_bucket_name)/ --recursive
```
