#!/bin/bash
sudo apt update -y
sudo apt install socat logrotate init-system-helpers adduser -y
sudo apt install wget -y
cd /tmp/
wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.10.7/rabbitmq-server_3.10.7-1_all.deb
sudo dpkg -i rabbitmq-server_3.10.7-1_all.deb
sudo rabbitmq-plugins enable rabbitmq_management
sudo systemctl start rabbitmq-server
sudo systemctl enable rabbitmq-server
sudo systemctl status rabbitmq-server
sudo sh -c 'echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config'
sudo rabbitmqctl add_user test test
sudo rabbitmqctl set_user_tags test administrator
sudo systemctl restart rabbitmq-server
