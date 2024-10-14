#!/bin/bash

# SELinux is not enforced on Ubuntu by default, but you can disable AppArmor instead (similar tool)
echo "Disabling AppArmor (Ubuntu equivalent to SELinux)."
sudo systemctl stop apparmor
sudo systemctl disable apparmor

# Install Erlang and RabbitMQ for Ubuntu
echo "Installing Erlang and RabbitMQ."
sudo apt update
sudo apt install -y curl gnupg apt-transport-https

# Add RabbitMQ and Erlang repository and import their GPG keys
curl -fsSL https://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc | sudo tee /usr/share/keyrings/erlang.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/erlang.gpg] https://packages.erlang-solutions.com/ubuntu $(lsb_release -cs) contrib" | sudo tee /etc/apt/sources.list.d/erlang.list

curl -fsSL https://packagecloud.io/rabbitmq/rabbitmq-server/gpgkey | sudo tee /usr/share/keyrings/rabbitmq.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/rabbitmq.gpg] https://packagecloud.io/rabbitmq/rabbitmq-server/ubuntu/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/rabbitmq.list

# Update package index and install Erlang and RabbitMQ
sudo apt update
sudo apt install -y erlang rabbitmq-server

# Check RabbitMQ installation
dpkg -l rabbitmq-server

# Start and enable RabbitMQ service
sudo systemctl start rabbitmq-server
sudo systemctl enable rabbitmq-server
sudo systemctl status rabbitmq-server

# Configure RabbitMQ
sudo bash -c 'echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.conf'

# Add RabbitMQ user
sudo rabbitmqctl add_user test test
sudo rabbitmqctl set_user_tags test administrator

# Open RabbitMQ ports (Ubuntu uses ufw instead of firewall-cmd)
sudo ufw allow 5671/tcp
sudo ufw allow 5672/tcp
sudo ufw reload

# Restart RabbitMQ service
sudo systemctl restart rabbitmq-server

# Optional reboot with delay
nohup sleep 30 && sudo reboot &
echo "Going to reboot now..."