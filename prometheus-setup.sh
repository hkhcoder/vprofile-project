#!/bin/bash

# Prometheus Installation Script
# Standard paths: /etc/prometheus (config), /var/lib/prometheus (data)
# Version: 3.5.0

set -e

# Set hostname
echo "prometheus" > /etc/hostname
hostname prometheus

# Variables
PROM_VERSION="3.5.1"
DOWNLOAD_URL="https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz"
TAR_FILE="prometheus-${PROM_VERSION}.linux-amd64.tar.gz"
EXTRACT_DIR="prometheus-${PROM_VERSION}.linux-amd64"
WORK_DIR="/tmp/prom"
CONFIG_DIR="/etc/prometheus"
DATA_DIR="/var/lib/prometheus"
BIN_DIR="/usr/local/bin"
SERVICE_FILE="/etc/systemd/system/prometheus.service"

# Create working directory
mkdir -p "${WORK_DIR}"
cd "${WORK_DIR}"

# Download and extract
wget "${DOWNLOAD_URL}"
tar xzvf "${TAR_FILE}"

# Create group and user
groupadd --system prometheus
useradd -s /sbin/nologin --system -g prometheus prometheus

# Create data directory
mkdir "${DATA_DIR}"
chown -R prometheus:prometheus "${DATA_DIR}"
chmod -R 775 "${DATA_DIR}"

# Create config subdirectories
mkdir -p "${CONFIG_DIR}/rules"
mkdir -p "${CONFIG_DIR}/rules.s"
mkdir -p "${CONFIG_DIR}/files_sd"

# Enter extracted directory
cd "${EXTRACT_DIR}"

# Move binaries
mv prometheus promtool "${BIN_DIR}"

# Check version
prometheus --version

# Move config file
mv prometheus.yml "${CONFIG_DIR}"

# Create systemd service file
cat > "${SERVICE_FILE}" << EOF
[Unit]
Description=Prometheus
Documentation=https://prometheus.io/docs/introduction/overview/
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP \$MAINPID
ExecStart=/usr/local/bin/prometheus \\
  --config.file=/etc/prometheus/prometheus.yml \\
  --storage.tsdb.path=/var/lib/prometheus \\
  --web.console.templates=/etc/prometheus/consoles \\
  --web.console.libraries=/etc/prometheus/console_libraries \\
  --web.listen-address=0.0.0.0:9090 \\
  --web.enable-remote-write-receiver

SyslogIdentifier=prometheus
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Set permissions
chown -R prometheus:prometheus "${CONFIG_DIR}"
chmod -R 775 "${CONFIG_DIR}"
chown -R prometheus:prometheus "${DATA_DIR}"

# Reload and start service
systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus
systemctl status prometheus --no-pager

# Display service file for verification
cat "${SERVICE_FILE}"
