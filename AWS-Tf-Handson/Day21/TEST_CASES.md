# 🧪 Test Cases: AWS Governance & Compliance (Day 21)

This document outlines the test scenarios to validate the infrastructure deployed in Day 21.

## ✅ Automated Verification (Infrastructure State)

Run the provided `verify_deployment.sh` script to confirm these checks.

| ID | Test Case | Expected Result |
|----|-----------|-----------------|
| **TC-01** | **S3 Bucket Existence** | Bucket created with correct naming convention. |
| **TC-02** | **S3 Versioning** | Versioning status is `Enabled`. |
| **TC-03** | **S3 Encryption** | Server-side encryption is `Enabled` (AES256/KMS). |
| **TC-04** | **S3 Public Access** | All 4 Public Access Block settings are `true`. |
| **TC-05** | **Config Recorder** | Recorder is created and `recording` status is `true`. |
| **TC-06** | **Config Rules** | All 6 compliance rules exist in AWS Config. |

---

## 🛑 Manual Compliance Testing (Negative Testing)

These tests verify that your **Preventive Controls (IAM Policies)** are actually blocking bad actions.

### TC-07: Verify MFA Delete Policy
**Objective:** Ensure the S3 bucket cannot be deleted without MFA.
1. **Pre-requisite:** You must be logged in as the `demo-user` (or assume the user's context).
2. **Action:** Try to delete the S3 bucket created by Terraform.
   ```bash
   aws s3 rb s3://<your-bucket-name>
   ```
3. **Expected Result:** `AccessDenied` error (because MFA is not present in the CLI command).

### TC-08: Verify Encryption Enforcement
**Objective:** Ensure objects cannot be uploaded via HTTP (unencrypted transport).
1. **Action:** Try to upload a file using standard HTTP (simulated).
   *Note: The AWS CLI uses HTTPS by default, so this is hard to trigger without using `curl` or specific API calls, but the policy `aws:SecureTransport` guarantees this.*
2. **Expected Result:** If attempted via non-SSL endpoint, request is Denied.

### TC-09: Verify Tagging Policy (If attached)
**Objective:** Ensure resources cannot be created without specific tags.
*Note: Ensure the `tagging_policy` is attached to your user before testing.*
1. **Action:** Try to launch an EC2 instance without tags.
   ```bash
   aws ec2 run-instances --image-id ami-12345678 --instance-type t2.micro
   ```
2. **Expected Result:** `UnauthorizedOperation` or `AccessDenied`.

---

## 🔍 AWS Config Compliance Testing (Detective Controls)

These tests verify that **AWS Config** detects non-compliant resources.

### TC-10: Detect Unencrypted Volumes
1. **Action:** Create an unencrypted EBS volume.
   ```bash
   aws ec2 create-volume --availability-zone $(aws ec2 describe-availability-zones --query 'AvailabilityZones[0].ZoneName' --output text) --size 1
   ```
2. **Wait:** Wait ~5-10 minutes for AWS Config to record the change.
3. **Check:** Go to AWS Console > Config > Rules > `encrypted-volumes`.
4. **Expected Result:** The new volume ID appears under **Non-compliant resources**.
5. **Cleanup:** Delete the volume.
   ```bash
   aws ec2 delete-volume --volume-id <vol-id>
   ```

### TC-11: Detect Public S3 Buckets
1. **Action:** Create a new S3 bucket and remove "Block Public Access" settings.
2. **Wait:** Wait ~5-10 minutes.
3. **Check:** Go to AWS Console > Config > Rules > `s3-bucket-public-write-prohibited`.
4. **Expected Result:** The bucket appears as **Non-compliant**.