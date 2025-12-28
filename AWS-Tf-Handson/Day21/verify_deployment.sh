#!/bin/bash

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "--------------------------------------------------"
echo "🕵️‍♂️ Identity & Account Check"
echo "--------------------------------------------------"

# 1. Force cleanup of conflicting Environment Variables
# This ensures the script relies ONLY on the profile, not exported keys
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN

# 2. Set the specific profile and expected account
export AWS_PROFILE="468284643560"
EXPECTED_ACCOUNT="468284643560"

echo "Using Profile: $AWS_PROFILE"

# 3. Verify Identity
CURRENT_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
CURRENT_ARN=$(aws sts get-caller-identity --query Arn --output text)

if [ "$CURRENT_ACCOUNT" != "$EXPECTED_ACCOUNT" ]; then
    echo -e "${RED}❌ CRITICAL ERROR: Wrong Account Detected${NC}"
    echo "--------------------------------------------------"
    echo "Expected Account: $EXPECTED_ACCOUNT"
    echo "Actual Account:   $CURRENT_ACCOUNT"
    echo "Actual Identity:  $CURRENT_ARN"
    echo "--------------------------------------------------"
    echo "👉 CAUSE: The profile '$AWS_PROFILE' in your ~/.aws/credentials file contains the WRONG keys."
    echo "          It is currently logging you in as 'dynamodb-training'."
    echo ""
    echo "👉 FIX: Open ~/.aws/credentials and update the [$AWS_PROFILE] section with the correct Access Keys."
    exit 1
else
    echo -e "${GREEN}✅ Identity Verified: Account $CURRENT_ACCOUNT${NC}"
fi

echo "--------------------------------------------------"
echo "🚀 Starting Infrastructure Verification"
echo "--------------------------------------------------"

# 4. Get Terraform Outputs
BUCKET_NAME=$(terraform output -raw s3_bucket_name)
RECORDER_NAME=$(terraform output -raw config_recorder_name)
REGION=$(terraform output -raw region 2>/dev/null || echo "us-west-1")

echo "Target Region:   $REGION"
echo "Target Bucket:   $BUCKET_NAME"
echo "Target Recorder: $RECORDER_NAME"

# 5. Verify S3 Versioning
echo "🔍 Checking S3 Versioning..."
VERSIONING=$(aws s3api get-bucket-versioning --bucket $BUCKET_NAME --region $REGION --query 'Status' --output text)
if [ "$VERSIONING" == "Enabled" ]; then
    echo -e "${GREEN}✅ Versioning is ENABLED${NC}"
else
    echo -e "${RED}❌ Versioning is NOT Enabled (Status: $VERSIONING)${NC}"
fi

# 6. Verify S3 Encryption
echo "🔍 Checking S3 Encryption..."
ENCRYPTION=$(aws s3api get-bucket-encryption --bucket $BUCKET_NAME --region $REGION --query 'ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault.SSEAlgorithm' --output text 2>/dev/null)
if [ "$ENCRYPTION" == "AES256" ] || [ "$ENCRYPTION" == "aws:kms" ]; then
    echo -e "${GREEN}✅ Encryption is ENABLED ($ENCRYPTION)${NC}"
else
    echo -e "${RED}❌ Encryption is NOT Enabled${NC}"
fi

# 7. Verify AWS Config Recorder
echo "🔍 Checking AWS Config Recorder..."
RECORDER_STATUS=$(aws configservice describe-configuration-recorder-status --configuration-recorder-names $RECORDER_NAME --region $REGION --query 'ConfigurationRecordersStatus[0].recording' --output text)
if [ "$RECORDER_STATUS" == "True" ]; then
    echo -e "${GREEN}✅ Config Recorder is RECORDING${NC}"
else
    echo -e "${RED}❌ Config Recorder is NOT recording (Status: $RECORDER_STATUS)${NC}"
fi

echo "--------------------------------------------------"
echo "🎉 Verification Complete"
echo "--------------------------------------------------"