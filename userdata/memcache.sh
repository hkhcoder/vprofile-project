#!/bin/bash
sudo dnf install epel-release -y
sudo dnf install memcached -y
# firewalld installation
sudo yum install firewalld -y
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo systemctl restart firewalld
sudo systemctl status firewalld
sudo systemctl start memcached
sudo systemctl enable memcached
sudo systemctl status memcached
sudo sed -i 's/127.0.0.1/0.0.0.0/g' /etc/sysconfig/memcached
sudo systemctl restart memcached
sudo firewall-cmd --add-port=11211/tcp
sudo firewall-cmd --runtime-to-permanent
sudo firewall-cmd --add-port=11111/udp
sudo firewall-cmd --runtime-to-permanent
sudo memcached -p 11211 -U 11111 -u memcached -d

