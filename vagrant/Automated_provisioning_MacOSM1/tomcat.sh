#!/bin/bash

# Variables
TOMURL="https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.75/bin/apache-tomcat-9.0.75.tar.gz"

# Install Java, Git, Maven, and wget
sudo apt update
sudo apt install openjdk-11-jdk git maven wget rsync -y

# Download and extract Tomcat
cd /tmp/
wget $TOMURL -O tomcatbin.tar.gz
EXTOUT=`tar xzvf tomcatbin.tar.gz`
TOMDIR=`echo $EXTOUT | cut -d '/' -f1`
sudo useradd --shell /usr/sbin/nologin tomcat
sudo rsync -avzh /tmp/$TOMDIR/ /usr/local/tomcat/
sudo chown -R tomcat:tomcat /usr/local/tomcat

# Create the Tomcat systemd service file
sudo rm -rf /etc/systemd/system/tomcat.service

sudo cat <<EOT | sudo tee /etc/systemd/system/tomcat.service
[Unit]
Description=Tomcat
After=network.target

[Service]
User=tomcat
Group=tomcat
WorkingDirectory=/usr/local/tomcat
Environment=JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
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

# Start and enable Tomcat service
sudo systemctl daemon-reload
sudo systemctl start tomcat
sudo systemctl enable tomcat

# Clone the repository and build with Maven
git clone -b main https://github.com/hkhcoder/vprofile-project.git
cd vprofile-project
mvn install

# Deploy the WAR file to Tomcat
sudo systemctl stop tomcat
sleep 60
sudo rm -rf /usr/local/tomcat/webapps/ROOT*
sudo cp target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war
sudo systemctl start tomcat

# Open the firewall for Tomcat's default port (8080)
sudo ufw allow 8080/tcp
sudo ufw reload

# Restart Tomcat
sudo systemctl restart tomcat