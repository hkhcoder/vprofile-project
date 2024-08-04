#!/bin/bash

TOMURL="https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.75/bin/apache-tomcat-9.0.75.tar.gz"

# Install JDK 17
dnf -y install java-17-openjdk java-17-openjdk-devel

# Install required tools
dnf install git maven wget -y

# Download and extract Tomcat
cd /tmp/
wget $TOMURL -O tomcatbin.tar.gz
EXTOUT=$(tar xzvf tomcatbin.tar.gz)
TOMDIR=$(echo $EXTOUT | cut -d '/' -f1)

# Create tomcat user and set permissions
useradd --shell /sbin/nologin tomcat
rsync -avzh /tmp/$TOMDIR/ /usr/local/tomcat/
chown -R tomcat.tomcat /usr/local/tomcat

# Remove existing systemd service file
rm -rf /etc/systemd/system/tomcat.service

# Create and configure the systemd service file for Tomcat
cat <<EOT>> /etc/systemd/system/tomcat.service
[Unit]
Description=Tomcat
After=network.target

[Service]
User=tomcat
Group=tomcat
WorkingDirectory=/usr/local/tomcat

Environment=JAVA_HOME=/usr/lib/jvm/jre

Environment=CATALINA_PID=/var/tomcat/%i/run/tomcat.pid
Environment=CATALINA_HOME=/usr/local/tomcat
Environment=CATALINA_BASE=/usr/local/tomcat

ExecStart=/usr/local/tomcat/bin/catalina.sh run
ExecStop=/usr/local/tomcat/bin/shutdown.sh

RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOT

# Reload systemd manager configuration
systemctl daemon-reload

# Start and enable Tomcat service
systemctl start tomcat
systemctl enable tomcat

# Clone the repository, build and deploy the application
git clone -b main https://github.com/hkhcoder/vprofile-project.git
cd vprofile-project
mvn install

# Stop Tomcat, replace ROOT.war, and start Tomcat
systemctl stop tomcat
sleep 20
rm -rf /usr/local/tomcat/webapps/ROOT*
cp target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war
systemctl start tomcat
sleep 20

# Stop and disable firewalld (if needed)
systemctl stop firewalld
systemctl disable firewalld

# Restart Tomcat service
systemctl restart tomcat
