#!/bin/bash

# Prometheus Installation Script (Improved)

set -e

# Ensure root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Set hostname
hostnamectl set-hostname prometheus

# Variables
PROM_VERSION="3.5.0"
DOWNLOAD_URL="https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz"
WORK_DIR="/tmp/prom"
CONFIG_DIR="/etc/prometheus"
DATA_DIR="/var/lib/prometheus"
BIN_DIR="/usr/local/bin"
SERVICE_FILE="/etc/systemd/system/prometheus.service"

# Create working directory
mkdir -p "${WORK_DIR}"
cd "${WORK_DIR}"

# Install dependencies
apt update -y
apt install -y wget tar

# Download and extract
wget -q "${DOWNLOAD_URL}"
tar -xzf "prometheus-${PROM_VERSION}.linux-amd64.tar.gz"

# Create user/group safely
id "prometheus" &>/dev/null || useradd -rs /bin/false prometheus

# Create directories
mkdir -p "${CONFIG_DIR}" "${DATA_DIR}" \
         "${CONFIG_DIR}/consoles" \
         "${CONFIG_DIR}/console_libraries"

# Enter extracted directory
cd "prometheus-${PROM_VERSION}.linux-amd64"

# Move binaries
cp prometheus promtool "${BIN_DIR}"

# Move config + consoles
cp prometheus.yml "${CONFIG_DIR}"
cp -r consoles/* "${CONFIG_DIR}/consoles/"
cp -r console_libraries/* "${CONFIG_DIR}/console_libraries/"

# Set permissions
chown -R prometheus:prometheus "${CONFIG_DIR}" "${DATA_DIR}"
chmod -R 755 "${CONFIG_DIR}" "${DATA_DIR}"

# Create systemd service
cat > "${SERVICE_FILE}" << EOF
[Unit]
Description=Prometheus
Documentation=https://prometheus.io/docs/introduction/overview/
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecReload=/bin/kill -HUP \$MAINPID
ExecStart=/usr/local/bin/prometheus \\
  --config.file=/etc/prometheus/prometheus.yml \\
  --storage.tsdb.path=/var/lib/prometheus \\
  --web.console.templates=/etc/prometheus/consoles \\
  --web.console.libraries=/etc/prometheus/console_libraries \\
  --web.listen-address=0.0.0.0:9090

Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Start service
systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus

echo "Prometheus installed successfully!"
echo "Access: http://<Your-IP>:9090""${SERVICE_FILE}"
