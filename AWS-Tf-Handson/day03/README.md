# Day 3: S3 Bucket

## Topics Covered
- Authentication and Authorization to AWS resources
- S3 bucket management

## Key Learning Points

### AWS Authentication
Before creating resources, you need to configure AWS credentials for Terraform to authenticate with AWS APIs.

### Authentication Methods
1. **AWS CLI Configuration**: `aws configure`
2. **Environment Variables**: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`
3. **IAM Roles**: For EC2 instances or AWS services
4. **AWS Profiles**: Named credential profiles

### S3 (Simple Storage Service)
Object storage service that offers scalability, data availability, security, and performance.

## Tasks for Practice

### Prerequisites
1. **Create AWS Account**: Sign up for AWS free tier if you don't have an account
2. **Install AWS CLI**: Download and install from AWS official website
3. **Configure Credentials**: Set up your AWS access keys

#### AWS CLI Installation

**Check your system architecture first:**
```bash
# Linux/macOS
uname -m

# Windows PowerShell
$env:PROCESSOR_ARCHITECTURE
```

**Official Website**: https://aws.amazon.com/cli/

**Windows:**
```powershell
# Using MSI installer (recommended)
# Download from: https://awscli.amazonaws.com/AWSCLIV2.msi

# Using winget
winget install Amazon.AWSCLI

# Using chocolatey
choco install awscli
```

**macOS:**
```bash
# Using official installer
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /

# Using Homebrew
brew install awscli
```

**Ubuntu/Debian:**
```bash
# Update package index
sudo apt update

# Install AWS CLI v2 (choose based on your architecture)
# For x86_64
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# For ARM64
curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"

unzip awscliv2.zip
sudo ./aws/install

# Verify installation
aws --version
```

### Authentication Setup

#### Method 1: AWS CLI Configuration
```bash
aws configure
```
Enter your:
- AWS Access Key ID
- AWS Secret Access Key
- Default region (e.g., us-east-1)
- Default output format (json)

#### Method 2: Environment Variables
```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

### Tasks to Complete
1. **Get familiar with Terraform AWS documentation**
   - Visit: https://registry.terraform.io/providers/hashicorp/aws/latest
   - Explore S3 resource documentation

2. **Create AWS resources using terraform**
   - S3 bucket with unique name

3. **Practice Terraform commands**
   - Initialize the working directory
   - Plan the infrastructure changes
   - Apply the configuration
   - Verify resources in AWS Console

### Important Notes
- **Resource Names**: S3 bucket names must be globally unique
- **Regions**: Ensure you're working in your intended AWS region
- **Costs**: Monitor AWS costs, even in free tier
- **Cleanup**: Always destroy resources when done practicing

### Common Commands
```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan changes
terraform plan

# Apply changes
terraform apply

# Show current state
terraform show

# Destroy resources
terraform destroy
```

### Troubleshooting Tips
- Check AWS credentials are properly configured
- Verify region settings match your intended deployment location
- Ensure S3 bucket names are unique and follow naming conventions
- Review AWS CloudTrail for API call logs if needed

## Next Steps
Proceed to Day 4 to learn about Terraform state file management and remote backends using S3 and DynamoDB.
