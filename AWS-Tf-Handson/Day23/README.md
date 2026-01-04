 # S3 Security & Operations Monitoring (Mini Project)

This project sets up a comprehensive monitoring stack for an S3 bucket using CloudTrail, CloudWatch Logs, Metric Filters, and CloudWatch Alarms. It alerts you via email (SNS) when suspicious activity occurs.

## Architecture

1.  **S3 Bucket**: A monitored bucket is created (with a random suffix).
2.  **CloudTrail**: Logs data events (object-level activity) for the bucket.
3.  **CloudWatch Logs**: Receives the CloudTrail logs.
4.  **Metric Filters**: Scans logs for:
    *   `AccessDenied` or `403` errors.
    *   Access to restricted prefixes (e.g., `private/*`).
5.  **CloudWatch Alarms**: Triggers when these metrics exceed the threshold (1 event).
6.  **SNS**: Sends an email notification when an alarm triggers.

## Prerequisites

*   Terraform installed.
*   AWS Credentials configured.

## Usage

1.  **Initialize Terraform:**

    ```bash
    terraform init
    ```

2.  **Plan the deployment:**
    Replace `your-email@example.com` with your actual email address.

    ```bash
    terraform plan -var="security_alert_email=your-email@example.com"
    ```

3.  **Apply the configuration:**

    ```bash
    terraform apply -var="security_alert_email=your-email@example.com"
    ```
    Type `yes` to confirm.

4.  **Confirm SNS Subscription:**
    Check your email inbox for a message from AWS SNS and click the "Confirm subscription" link. **You will not receive alerts until you do this.**

## Testing the Alerts (Demo Guide)

1.  **Get the Bucket Name:**
    Run `terraform output monitored_bucket_name` to see the created bucket name.

2.  **Trigger a Restricted Prefix Alert:**
    The project automatically uploads a test file to `private/secret-file.txt`. Accessing this file will trigger the "Restricted Prefix" alarm.
    
    ```bash
    # Get the bucket name from output
    BUCKET_NAME=$(terraform output -raw monitored_bucket_name)
    
    # Download the secret file (this counts as access)
    aws s3 cp s3://$BUCKET_NAME/private/secret-file.txt downloaded-secret.txt
    ```

3.  **Trigger an Access Denied Error:**
    Try to access a non-existent object. This generates a 403/404 error which the "Denied Requests" filter picks up.
    
    ```bash
    aws s3 cp s3://$BUCKET_NAME/ghost-file.txt .
    ```

4.  **Verify:**
    *   Go to the **AWS Console -> CloudWatch -> Alarms**.
    *   You should see the alarms go into `ALARM` state after a few minutes (CloudTrail logs can take 5-15 mins to appear).
    *   Check your email for the notification.

## Cleanup

To destroy the resources:

```bash
terraform destroy -var="security_alert_email=your-email@example.com"
```
