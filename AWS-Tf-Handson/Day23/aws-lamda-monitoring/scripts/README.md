# Deployment Scripts & Manual Build Instructions

This directory contains the automation scripts for the Image Processor project.

## Scripts

### `deploy.sh`
Full deployment automation:
1. Checks for AWS CLI and Terraform prerequisites.
2. **Attempts to build the Lambda layer using Docker.**
3. Initializes and applies Terraform configuration.
4. Outputs S3 bucket names and usage instructions.

### `destroy.sh`
Cleanup automation:
1. Empties all project S3 buckets (handling versioned objects and delete markers).
2. Destroys Terraform resources.

---

## ⚠️ Manual Layer Build (If Docker Fails)

If you are unable to run Docker (e.g., on older macOS versions), the `deploy.sh` script will fail at the build step. You must manually create the `pillow_layer.zip` file using the steps below.

### Prerequisites
- Python 3.9 installed locally.
- `pip` installed.

### Steps to Create `pillow_layer.zip`
Run these commands from the **project root** directory:

1. **Create a temporary build directory:**
   ```bash
   mkdir -p pillow-layer/python
   ```

2. **Install the Linux-compatible Pillow library:**
   We use specific flags to download the binary compatible with AWS Lambda (Amazon Linux 2), rather than the macOS version.
   ```bash
   pip install Pillow \
       --platform manylinux2014_x86_64 \
       --target ./pillow-layer/python \
       --implementation cp \
       --python-version 3.9 \
       --only-binary=:all: \
       --upgrade
   ```

3. **Zip the artifact:**
   ```bash
   cd pillow-layer
   zip -r ../pillow_layer.zip python
   cd ..
   rm -rf pillow-layer
   ```