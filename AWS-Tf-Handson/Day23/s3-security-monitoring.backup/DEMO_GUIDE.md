# S3 Security Monitoring - Complete Demo Script

This is your **one-stop reference guide** for recording the entire demo in one shot. Follow this sequentially from top to bottom. Every section includes what to show, what to say, and why it matters.

---

## PART 1: Pre-Recording Checklist

### Browser Tabs to Open (Pre-login to AWS Console)
1. **AWS S3 Console** - To show the monitored bucket after creation.
2. **AWS CloudWatch > Alarms** - To show alarm states changing from OK → ALARM.
3. **AWS CloudWatch > Log Groups** - To show the CloudTrail logs streaming in.
4. **AWS CloudWatch > Metrics > Custom** - To show the Security/S3 custom metrics.
5. **AWS SNS > Subscriptions** - To show the subscription confirmation process.
6. **Gmail/Email Inbox** - To show the confirmation email and alarm notifications.

### VS Code Setup
- Open folder: `lessons/day23/s3-security-monitoring`
- Open integrated terminal
- Have `main.tf` visible in the editor
- Ensure you've run `terraform destroy` to start fresh

---

## PART 2: Introduction & Problem Statement (30-45 seconds)

### What to Show
- Your face or screen with the project folder open in VS Code.

### What to Say
> "Welcome to Day 23 of the Terraform AWS Course. Today we're tackling a real-world security challenge: **How do you monitor your S3 buckets for suspicious activity?**
>
> Imagine this scenario: Someone is trying to access files in your restricted folders, or they're getting Access Denied errors repeatedly. These could be signs of a breach attempt, misconfiguration, or insider threat.
>
> We're going to build an **automated security monitoring system** that:
> 1. Captures every single file access attempt using **CloudTrail**
> 2. Analyzes the logs for suspicious patterns using **CloudWatch Metric Filters**
> 3. Triggers **real-time email alerts** when something looks wrong
> 4. And it's all defined as code using **Terraform modules** so you can reuse it across multiple buckets or environments."

### Why This Matters
**Explain:** Most teams only check S3 logs manually after an incident. This solution catches problems **as they happen**.

---

## PART 3: Architecture & Code Walkthrough (2-3 minutes)

### What to Show
Screen recording of VS Code showing the folder structure and key files.

### Module 1: Project Structure

**Show:** The folder tree in VS Code Explorer.

**What to Say:**
> "Let's look at how this is organized. This is a **modular Terraform project** with four independent modules:
>
> - `modules/sns_security` - Creates the SNS topic and email subscription for alerts
> - `modules/log_ingest_s3` - Sets up the S3 bucket, CloudTrail, and CloudWatch Log Group
> - `modules/security_metrics` - Defines the metric filters that scan logs for patterns
> - `modules/security_alarms` - Creates the alarms that trigger when metrics spike
>
> The root `main.tf` wires these together, passing outputs from one module as inputs to the next."

**Why This Matters:** Explain that this modularity means you can reuse individual modules in other projects (e.g., use the same SNS module for RDS monitoring).

---

### Module 2: SNS Security Module

**Show:** Open `modules/sns_security/main.tf`

**What to Say:**
> "The SNS module is simple but critical. It creates:
> 1. An SNS topic named `s3-security-alerts-topic`
> 2. An email subscription to that topic
>
> Notice we're passing in `var.security_alert_email` from the root module. This makes it reusable—you can use the same module for dev, staging, and production with different emails."

**Point Out:** The `aws_sns_topic_subscription` resource. Mention that it will be in "Pending Confirmation" state until we click the email link.

---

### Module 3: Log Ingest Module

**Show:** Open `modules/log_ingest_s3/main.tf`

**What to Say:**
> "This is the data collection layer. Let me walk through what it creates:
>
> 1. **Monitored Bucket** - The S3 bucket we want to watch. Note `force_destroy = true` so Terraform can delete it even if it has files.
>
> 2. **Trail Logs Bucket** - CloudTrail needs a place to store its raw logs. This is a separate bucket with a policy allowing CloudTrail to write to it.
>
> 3. **CloudWatch Log Group** - This is where we'll analyze the logs. CloudTrail sends a copy of all S3 data events here.
>
> 4. **IAM Role** - CloudTrail needs permission to write to CloudWatch Logs. This role gives it that permission.
>
> 5. **CloudTrail** - This is configured with `event_selector` to capture *data events* (file access) on our monitored bucket. By default, CloudTrail only logs management events like creating/deleting buckets. We need data events to see who accessed which files.
>
> 6. **Test File** - We automatically upload `private/secret-file.txt` so we have something to test with. This file will trigger alarms when accessed."

**Why This Matters:** Without CloudTrail data events, you'd only see bucket-level actions, not file-level access. This is the key to granular security monitoring.

---

### Module 4: Security Metrics Module

**Show:** Open `modules/security_metrics/main.tf`

**What to Say:**
> "This is where we define *what to look for* in the logs. We create two metric filters:
>
> **Filter 1: Denied Requests**
> - Pattern: `{ $.errorCode = \"AccessDenied\" || $.errorCode = \"403\" }`
> - This matches any log entry where someone got a 403 or Access Denied error
> - Each match increments a custom metric called `DeniedRequests` by 1
> - Namespace: `Security/S3` (this is how we organize custom metrics)
>
> **Filter 2: Restricted Prefix**
> - Pattern: `{ $.requestParameters.key = \"private/*\" }`
> - This matches any access to files under the `private/` folder
> - Each match increments `RestrictedPrefixAccess` by 1
>
> These patterns use CloudWatch Logs filter syntax, which is JSON-based. The `$` represents the root of the JSON log entry from CloudTrail."

**Point Out:** You can add more filters for other patterns like `DELETE` operations, access from unusual IP ranges, or high-volume downloads.

---

### Module 5: Security Alarms Module

**Show:** Open `modules/security_alarms/main.tf`

**What to Say:**
> "Now we turn metrics into actionable alerts. We create two alarms:
>
> **Alarm 1: DeniedRequestsAlarm**
> - Watches the `DeniedRequests` metric
> - Threshold: Greater than or equal to 1
> - Period: 60 seconds
> - Statistic: Sum
> - Meaning: If we see even 1 denied request in a minute, trigger the alarm
>
> **Alarm 2: RestrictedPrefixAccessAlarm**
> - Watches `RestrictedPrefixAccess`
> - Same threshold and period
>
> Both alarms send notifications to the SNS topic ARN we created in the first module. That's how the email gets sent."

**Why This Matters:** The threshold of 1 is intentionally low for the demo. In production, you'd set it higher (e.g., 10 denied requests in 5 minutes) to avoid alert fatigue.

---

### Module 6: Root Module Orchestration

**Show:** Open `main.tf` in the root

**What to Say:**
> "Finally, the root module ties everything together. Look at the flow:
>
> 1. We instantiate `sns_security` and get back `sns_topic_arn`
> 2. We instantiate `log_ingest_s3` and get back `log_group_name`
> 3. We pass `log_group_name` to `security_metrics`
> 4. We pass the metric names AND `sns_topic_arn` to `security_alarms`
>
> This is module composition in action. Each module is focused on one job, and we connect them through inputs and outputs."

**Show:** Open `variables.tf` and point out the three variables: `region`, `security_alert_email`, and `monitored_bucket_name`.

---

## PART 4: Deployment (1-2 minutes)

### What to Show
Terminal in VS Code, full screen.

### Commands to Run

**Step 1: Initialize Terraform**

```bash
terraform init
```

**What to Say:**
> "First, we initialize Terraform. This downloads the AWS provider and sets up the backend."

**Wait for output:** Show the "Terraform has been successfully initialized!" message.

---

**Step 2: Apply the Configuration**

```bash
terraform apply -var="security_alert_email=your-email@gmail.com" -auto-approve
```

**What to Say:**
> "Now we apply. I'm passing my email as a variable. Terraform will create 15 resources:
> - 2 S3 buckets
> - 1 CloudTrail
> - 1 CloudWatch Log Group
> - 2 Metric Filters
> - 2 Alarms
> - 1 SNS Topic and Subscription
> - Plus IAM roles and policies
>
> This should take about 30-40 seconds."

**While it's running:** You can narrate what's happening:
> "See how it's creating resources in parallel? The SNS topic, S3 buckets, and log group can all be created at the same time because they don't depend on each other. The CloudTrail waits for the bucket policy, and the alarms wait for the SNS topic. This is Terraform's dependency graph at work."

**After completion:** Show the outputs:

```
Outputs:
log_group_name = "/aws/cloudtrail/my-secure-bucket"
monitored_bucket_name = "my-secure-bucket-afae410a"
sns_topic_arn = "arn:aws:sns:us-east-1:123456789012:s3-security-alerts-topic"
```

**What to Say:**
> "Great! Everything is created. Notice the bucket name has a random suffix—this ensures uniqueness. Let's save that bucket name for testing later."

---

## PART 5: SNS Subscription Confirmation (Critical Step - 1 minute)

## PART 5: SNS Subscription Confirmation (Critical Step - 1 minute)

### What to Show
Split screen: AWS SNS Console on one side, Gmail inbox on the other.

### Step-by-Step Actions

**Action 1:** Switch to **AWS Console > SNS > Subscriptions**

**What to Say:**
> "Before we can receive alerts, we need to confirm the email subscription. Look at the subscriptions list—you'll see my email with status 'Pending confirmation'. AWS does this to prevent spam. You can't just subscribe random people to your topics."

**Action 2:** Switch to your **Email Inbox**

**What to Say:**
> "I should have an email from `no-reply@sns.amazonaws.com` with the subject 'AWS Notification - Subscription Confirmation'. Here it is."

**Show:** Open the email (blur personal details if needed).

**Action 3:** Click the **"Confirm subscription"** link in the email

**What to Say:**
> "I'll click this link. It opens a browser page saying 'Subscription confirmed!'."

**Action 4:** Go back to **AWS Console > SNS > Subscriptions** and refresh

**What to Say:**
> "Now if I refresh the SNS subscriptions page... there we go! Status changed from 'Pending' to 'Confirmed'. Now the system is live and ready to send alerts."

**Why This Matters:** Emphasize that this is a one-time step. Once confirmed, the subscription stays active unless someone clicks "Unsubscribe" in a future email.

---

## PART 6: Triggering the Alarms (The Demo Payoff - 3-4 minutes)

### What to Show
Terminal for commands, then switch to AWS Console to show results.

### Test Scenario 1: Restricted File Access

**What to Say:**
> "Alright, let's trigger some alarms. Remember, we have a rule: Files in the `private/` folder are restricted. Terraform already uploaded a test file there called `secret-file.txt`. Let's try to access it."

**Commands to Run:**

```bash
# Save the bucket name to a variable for convenience
BUCKET=$(terraform output -raw monitored_bucket_name)

# Show the bucket name
echo "Monitored Bucket: $BUCKET"

# Download the restricted file
aws s3 cp s3://$BUCKET/private/secret-file.txt downloaded-secret.txt
```

**What to Say After Running:**
> "The download succeeded because I have admin permissions. But here's the key: CloudTrail logged this access. The metric filter will see 'private/' in the key path and increment the `RestrictedPrefixAccess` metric. That will trip the alarm."

**Show:** Open the file in VS Code or `cat` it to show the contents: "This is a secret file..."

---

### Test Scenario 2: Access Denied Error

**What to Say:**
> "Now let's simulate an attacker guessing filenames. They don't know what files exist, so they'll try random names and get errors."

**Commands to Run:**

```bash
# Try to access a file that doesn't exist
aws s3 cp s3://$BUCKET/ghost-file.txt .

# Try another one to generate multiple errors
aws s3 cp s3://$BUCKET/classified-data.txt .
```

**Expected Output:** You'll see errors like:
```
fatal error: An error occurred (404) when calling the HeadObject operation: Not Found
```

**What to Say:**
> "Perfect! These 404 errors get logged by CloudTrail. The metric filter is looking for error codes 403 or 404, and each one increments the `DeniedRequests` metric. Now we wait for the alarms to fire."

---

### The Waiting Game (Important: Set Expectations)

**What to Say:**
> "Here's the reality: CloudTrail logs don't appear instantly. There's a delay of about 5 to 15 minutes from when the event happens to when it shows up in CloudWatch Logs. So let's use this time to look at what's happening behind the scenes."

---

### Checking the Logs (While Waiting)

**Action:** Switch to **AWS Console > CloudWatch > Log Groups**

**What to Say:**
> "Let's check the log group. Go to CloudWatch > Log groups, and find `/aws/cloudtrail/my-secure-bucket`."

**Show:** Click on the log group, then click on a log stream.

**What to Say:**
> "These log streams contain the raw CloudTrail events. Each entry is a JSON object. Let me expand one... see, here's the event name 'GetObject', the bucket name, the key 'private/secret-file.txt', and the user who accessed it. This is the data our metric filters are scanning."

**Point Out:** The `eventName`, `errorCode`, and `requestParameters.key` fields—these are what the filters match against.

---

### Checking the Metrics

**Action:** Go to **CloudWatch > Metrics > All Metrics > Security/S3**

**What to Say:**
> "Now let's look at the custom metrics. Go to CloudWatch > Metrics, click 'All metrics', then 'Security/S3'. Here are our two custom metrics: `DeniedRequests` and `RestrictedPrefixAccess`."

**Show:** Select both metrics and change the graph to show the last 15 minutes with 1-minute periods.

**What to Say:**
> "See these data points? Each spike represents one event. The `RestrictedPrefixAccess` has a value of 1 because we accessed the secret file once. The `DeniedRequests` has a value of 2 because we tried to access two non-existent files."

---

### Checking the Alarms

**Action:** Go to **CloudWatch > Alarms**

**What to Say:**
> "Now the moment of truth. Let's check the alarms. Here they are: `DeniedRequestsAlarm` and `RestrictedPrefixAccessAlarm`."

**Expected State:** They should be in **"In alarm"** (red) state.

**Show:** Click on one alarm to see the details.

**What to Say:**
> "Look at the alarm history. It was in 'OK' state when we first created it. Then at [timestamp], it transitioned to 'ALARM' because the metric crossed the threshold. The reason is listed here: 'Threshold Crossed: 1 datapoint was greater than the threshold (1.0).'
>
> And most importantly, it triggered the action: Send notification to the SNS topic. That's when the email was sent."

---

### The Email Alert (The Final Proof)

**Action:** Switch to your **Email Inbox**

**What to Say:**
> "And here's the payoff. I have two emails from AWS CloudWatch."

**Show:** Open the first email.

**What to Say:**
> "Subject: 'ALARM: RestrictedPrefixAccessAlarm in US East (N. Virginia)'. The body tells me:
> - Alarm Name
> - Alarm Description: 'This metric monitors access to restricted prefixes in S3'
> - The metric value that triggered it
> - The timestamp
> - A link to view the alarm in the console
>
> As a security admin, this tells me immediately: Someone accessed a file in the restricted folder. I need to investigate."

**Show:** Open the second email for the `DeniedRequestsAlarm`.

**What to Say:**
> "And this second one: 'ALARM: DeniedRequestsAlarm'. Someone is getting Access Denied errors. This could be a misconfigured application, or it could be an attacker probing the bucket. Either way, I know about it in near real-time."

---

## PART 7: Recap & Best Practices (1 minute)

### What to Say

> "Let's recap what we built:
>
> **Data Collection Layer:**
> - CloudTrail captures every S3 API call (GetObject, PutObject, DeleteObject, etc.)
> - Logs flow into a CloudWatch Log Group for analysis
>
> **Analysis Layer:**
> - Metric Filters scan the logs for patterns (errors, restricted paths)
> - Convert log events into numerical metrics we can graph and alert on
>
> **Action Layer:**
> - CloudWatch Alarms watch those metrics
> - When a threshold is crossed, they send notifications via SNS
> - Subscribed users get instant email alerts
>
> **Why This Approach Works:**
> 1. **Serverless** - No infrastructure to maintain. CloudWatch and SNS are fully managed.
> 2. **Near Real-Time** - Alerts arrive within minutes of an event.
> 3. **Customizable** - You can add more metric filters for any pattern you care about.
> 4. **Reusable** - These Terraform modules can monitor any S3 bucket, or adapt them for other AWS services.
>
> **Production Considerations:**
> - Adjust alarm thresholds to avoid alert fatigue (e.g., 10 errors in 5 minutes instead of 1)
> - Add multiple SNS subscriptions (email, Slack, PagerDuty)
> - Use CloudWatch Logs Insights for ad-hoc queries during investigations
> - Consider archiving logs to S3 for long-term compliance (CloudWatch Logs retention is only 7 days in our example)"

---

## PART 8: Cleanup (30 seconds)

### What to Show
Terminal.

### Command to Run

```bash
terraform destroy -var="security_alert_email=your-email@gmail.com" -auto-approve
```

### What to Say
> "Finally, cleanup is just one command. Terraform will delete all 15 resources in the reverse order of their dependencies. The buckets will be emptied automatically because we set `force_destroy = true`."

**While it's running:**
> "In about 30 seconds, everything will be gone. No lingering costs, no orphaned resources. This is the beauty of Infrastructure as Code."

---

## PART 9: Closing (15 seconds)

### What to Say
> "That's it for Day 23! You now know how to build production-grade security monitoring for AWS S3 using CloudTrail, CloudWatch, and SNS—all managed as code with Terraform modules. In the next lesson, we'll look at [preview next topic]. Thanks for watching, and I'll see you in the next one!"

---

## Quick Reference: Commands Cheat Sheet

```bash
# Initialize
terraform init

# Deploy
terraform apply -var="security_alert_email=your@email.com" -auto-approve

# Get bucket name
terraform output -raw monitored_bucket_name

# Test restricted access
BUCKET=$(terraform output -raw monitored_bucket_name)
aws s3 cp s3://$BUCKET/private/secret-file.txt downloaded-secret.txt

# Test access denied
aws s3 cp s3://$BUCKET/ghost-file.txt .

# Cleanup
terraform destroy -var="security_alert_email=your@email.com" -auto-approve
```

---

## Troubleshooting Tips for Recording

**If alarms don't trigger:**
- Wait 15 minutes. CloudTrail can be slow.
- Check the log group has new log streams.
- Verify metric filters are created (CloudWatch > Log groups > [your group] > Metric filters).

**If SNS subscription keeps going to "Pending":**
- Make sure you're clicking the link in the *newest* email.
- Delete old confirmation emails to avoid confusion.
- Check your spam folder.

**If you make a mistake while recording:**
- Don't stop! Just say "Let me try that again" and redo the step. You can edit it out later.
- Keep a backup terminal tab with the commands pre-typed.
