# Demo Guide: AWS Policy and Governance (Day 21)

---

## 📖 Part 1: Theory & Concepts (Explain First)

### What is AWS Governance?

Governance = **Rules + Enforcement + Monitoring**

It ensures your AWS resources follow security and compliance standards automatically.

### Why Do We Need It?

| Problem | Solution |
|---------|----------|
| Developers create public S3 buckets | Config rule detects & alerts |
| EC2 launched without tags | IAM policy blocks it |
| Someone deletes critical data | MFA policy prevents it |
| Manual audits are slow | Automated 24/7 monitoring |

### Two Types of Controls

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│   1. PREVENTIVE (IAM Policies)                      │
│      → Blocks bad actions BEFORE they happen        │
│      → Example: "Cannot delete S3 without MFA"      │
│                                                     │
│   2. DETECTIVE (AWS Config)                         │
│      → Finds violations AFTER they happen           │
│      → Example: "This bucket is not encrypted"      │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Architecture Overview

```
         ┌──────────────────┐
         │   IAM POLICIES   │  ◄── PREVENT bad actions
         │  • MFA Delete    │
         │  • Encryption    │
         │  • Required Tags │
         └────────┬─────────┘
                  │
                  ▼
         ┌──────────────────┐
         │   AWS CONFIG     │  ◄── DETECT violations
         │   6 Rules        │
         │  (Compliance)    │
         └────────┬─────────┘
                  │
                  ▼
         ┌──────────────────┐
         │    S3 BUCKET     │  ◄── STORE logs
         │  🔒 Encrypted    │
         │  🔒 Versioned    │
         └──────────────────┘
```

### What We'll Build

| Component | Count | Purpose |
|-----------|-------|---------|
| IAM Policies | 3 | Prevent bad actions |
| IAM User | 1 | Demo policy attachment |
| S3 Bucket | 1 | Secure log storage |
| Config Rules | 6 | Compliance checks |
| Config Recorder | 1 | Monitor resources |

---

## 🛠️ Part 2: Demo - File by File Explanation

### File Structure

```
day21/
├── provider.tf    → AWS provider setup
├── variables.tf   → Customizable inputs
├── iam.tf         → Policies (PREVENT)
├── config.tf      → Config rules (DETECT)
├── main.tf        → S3 bucket (STORE)
└── outputs.tf     → Display results
```

---

### 📄 provider.tf - AWS Provider

**What it does:** Tells Terraform to use AWS

```hcl
provider "aws" {
  region = var.aws_region   # us-east-1 by default
}
```

**Explain:** This connects Terraform to your AWS account.

---

### 📄 variables.tf - Inputs

**What it does:** Makes the code reusable

```hcl
variable "aws_region" {
  default = "us-east-1"
}

variable "project_name" {
  default = "terraform-governance-demo"
}
```

**Explain:** You can change region or project name without editing other files.

---

### 📄 iam.tf - IAM Policies (PREVENTIVE CONTROLS)

**What it does:** Creates 3 security policies

#### Policy 1: MFA Delete Policy

```hcl
# Denies S3 deletion unless user has MFA
"Condition": {
  "BoolIfExists": {
    "aws:MultiFactorAuthPresent": "false"
  }
}
```

**Explain:** 
- If someone tries to delete S3 objects WITHOUT MFA → DENIED
- Protects critical data from accidental deletion

#### Policy 2: S3 Encryption in Transit

```hcl
# Denies uploads over HTTP (requires HTTPS)
"Condition": {
  "Bool": {
    "aws:SecureTransport": "false"
  }
}
```

**Explain:**
- Forces all S3 uploads to use HTTPS
- Prevents man-in-the-middle attacks

#### Policy 3: Required Tags

```hcl
# Denies EC2 creation without Environment + Owner tags
"Condition": {
  "Null": {
    "aws:RequestTag/Owner": "true"
  }
}
```

**Explain:**
- Cannot launch EC2 without proper tags
- Helps with cost tracking and accountability

#### Demo User

```hcl
resource "aws_iam_user" "demo_user" {
  name = "terraform-governance-demo-demo-user"
}
```

**Explain:** Creates a user and attaches the MFA policy to show how policies work in practice.

---

### 📄 config.tf - AWS Config (DETECTIVE CONTROLS)

**What it does:** Creates Config recorder + 6 compliance rules

#### Config Recorder

```hcl
resource "aws_config_configuration_recorder" "main" {
  recording_group {
    all_supported = true  # Monitor ALL resource types
  }
}
```

**Explain:** This records every configuration change in your AWS account.

#### Config Rule Example: S3 Encryption

```hcl
resource "aws_config_config_rule" "s3_encryption" {
  name = "s3-bucket-server-side-encryption-enabled"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }
}
```

**Explain:** 
- AWS provides pre-built rules (managed rules)
- This checks if ALL S3 buckets have encryption enabled
- Non-compliant buckets are flagged

#### All 6 Rules We Create

| Rule | What It Checks |
|------|----------------|
| `s3-bucket-public-write-prohibited` | No public write access |
| `s3-bucket-server-side-encryption-enabled` | Encryption enabled |
| `s3-bucket-public-read-prohibited` | No public read access |
| `encrypted-volumes` | EBS volumes encrypted |
| `required-tags` | Has Environment + Owner tags |
| `root-account-mfa-enabled` | Root has MFA |

---

### 📄 main.tf - S3 Bucket (SECURE STORAGE)

**What it does:** Creates a fully secured S3 bucket for Config logs

```hcl
# Versioning - keeps history
resource "aws_s3_bucket_versioning" {
  status = "Enabled"
}

# Encryption - protects data at rest
resource "aws_s3_bucket_server_side_encryption_configuration" {
  sse_algorithm = "AES256"
}

# Block public access - all 4 settings ON
resource "aws_s3_bucket_public_access_block" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

**Explain:** This bucket follows ALL the security best practices we're checking with Config rules. It's compliant by design!

---

### 📄 outputs.tf - Display Results

**What it does:** Shows important information after deployment

```hcl
output "config_rules" {
  value = [list of all rule names]
}

output "config_recorder_status" {
  value = true  # Recorder is running
}
```

---

## 🚀 Part 3: Run the Demo

### Step 1: Initialize

```bash
terraform init
```

**Explain:** Downloads AWS provider plugins.

### Step 2: Plan

```bash
terraform plan
```

**Explain:** Shows 23 resources will be created. Walk through key ones:
- IAM policies
- S3 bucket with security settings
- Config recorder
- 6 Config rules

### Step 3: Apply

```bash
terraform apply -auto-approve
```

**Explain:** Takes 2-3 minutes. Creates everything.

### Step 4: View Outputs

```bash
terraform output
```

**Show:**
- Policy ARNs
- S3 bucket name
- Config recorder status = true
- List of 6 rules

---

## 🔍 Part 4: Verify in AWS Console

### Check IAM Policies

```bash
aws iam list-policies --scope Local | grep terraform-governance
```

**Console:** IAM → Policies → Filter "Customer managed"

**Show:** Click on MFA policy → View JSON → Explain the condition

### Check S3 Bucket

```bash
aws s3api get-bucket-encryption --bucket $(terraform output -raw config_bucket_name)
```

**Console:** S3 → Find bucket → Properties tab

**Show:**
- ✅ Versioning: Enabled
- ✅ Encryption: AES-256
- ✅ Block public access: All ON

### Check AWS Config

```bash
aws configservice describe-configuration-recorder-status
```

**Console:** AWS Config → Dashboard → Rules

**Show:**
- Recorder running
- 6 rules listed
- Compliance status (may take 5-10 min)

---

## 🧪 Part 5: Test Compliance Detection

### Create a Violation

```bash
# Create bucket WITHOUT encryption
aws s3 mb s3://test-violation-$(date +%s)
```

### Check Config

**Wait 2-3 minutes, then:**

1. Go to AWS Config → Rules
2. Click "s3-bucket-server-side-encryption-enabled"
3. See new bucket as **NON-COMPLIANT** (red)

**Explain:** Config detected the violation automatically!

### Cleanup Test

```bash
aws s3 rb s3://test-violation-* --force
```

---

## 🧹 Part 6: Cleanup

```bash
terraform destroy -auto-approve
```

**Explain:** Removes all 23 resources. Important for cost control.

---

## 💡 Key Takeaways

1. **IAM Policies = PREVENT** → Block bad actions before they happen
2. **AWS Config = DETECT** → Find violations after they happen
3. **Defense in Depth** → Use both for complete protection
4. **Infrastructure as Code** → Governance is version controlled
5. **Automated Compliance** → 24/7 monitoring, no manual audits

---

## 📊 Quick Reference

| File | Purpose | Controls |
|------|---------|----------|
| `iam.tf` | Policies | Preventive |
| `config.tf` | Rules | Detective |
| `main.tf` | S3 Bucket | Storage |

| Commands | |
|----------|---|
| `terraform init` | Setup |
| `terraform plan` | Preview |
| `terraform apply` | Deploy |
| `terraform output` | View results |
| `terraform destroy` | Cleanup |

---

**Demo Time: ~30 minutes**

**Cost: ~$2/month (destroy after demo)**