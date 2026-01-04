# Logical Flow of Infrastructure Code

To understand how this infrastructure is built, follow this sequence of files. This order respects the dependencies: you can't build servers without a network, and you can't load balance without servers.

## 1. The Foundation: `main.tf` & `vpc.tf`
**Start here.** Before you can build servers, you need a network.
*   **`main.tf`**: Configures the AWS Provider and sets global tags.
*   **`vpc.tf`**: Builds the "Virtual Data Center".
    *   **VPC**: The isolated network container.
    *   **Public Subnets**: Where the Load Balancer and NAT Gateways live (they need to talk to the internet).
    *   **Private Subnets**: Where your actual Application Servers will live (hidden from the internet for security).
    *   **NAT Gateways**: Allow your private servers to download updates without letting hackers in.

## 2. The Firewall: `security_groups.tf`
**Read this next.** This defines *who* is allowed to talk to *whom*.
*   **`alb_sg`**: The "Doorman". It allows HTTP/HTTPS traffic from **Anywhere** (`0.0.0.0/0`).
*   **`app_sg`**: The "VIP Section". It **only** allows traffic coming from the `alb_sg`. This is crucial—it prevents anyone from bypassing the Load Balancer to hit your servers directly.

## 3. The Front Door: `alb.tf`
**Now we connect the Network and Security.**
*   **`aws_lb`**: The Load Balancer. It sits in the **Public Subnets** (from `vpc.tf`) and wears the **`alb_sg`** security badge (from `security_groups.tf`).
*   **`aws_lb_target_group`**: The "Waiting Room". The Load Balancer sends valid requests here.
*   **`aws_lb_listener`**: Listens on Port 80 and points traffic to that Target Group.

## 4. The Application Fleet: `asg.tf`
**This is where the actual servers are created.**
*   **`aws_launch_template`**: The "Blueprint". It says "Create servers using this AMI, this Instance Type, and attach the **`app_sg`** security group."
*   **`aws_autoscaling_group`**: The "Manager".
    *   It launches servers into the **Private Subnets** (from `vpc.tf`).
    *   It registers them with the **Target Group** (from `alb.tf`) so they start receiving traffic.
    *   It watches **CloudWatch Alarms** (High/Low CPU) to decide if it should add or remove servers.

## 5. The Storage: `s3.tf`
**The Sidecar.**
*   This creates a secure bucket for your application to store files. While it doesn't "depend" on the networking files like the others do, your application running on the EC2 instances will likely use IAM roles to read/write to this bucket.

---

## Summary of the Data Flow
1.  **User** -> hits **Load Balancer** (in Public Subnet, allowed by `alb_sg`).
2.  **Load Balancer** -> forwards to **Target Group**.
3.  **Target Group** -> routes to an **EC2 Instance** (in Private Subnet, allowed by `app_sg`).
4.  **EC2 Instance** -> processes request (and maybe saves a file to **S3**).
5.  **EC2 Instance** -> sends response back through the Load Balancer to the User.
