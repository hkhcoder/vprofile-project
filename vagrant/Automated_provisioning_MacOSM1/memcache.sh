#!/bin/bash

# On Ubuntu, we don't have a yum repository, so we skip moving repo files

# Clean any cached data
sudo apt clean

# Install Memcached and related tools
sudo apt update
sudo apt install memcached -y
sudo systemctl start memcached
sudo systemctl enable memcached
sudo systemctl status memcached

# Open Memcached port (11211) using UFW (Ubuntu's firewall utility)
sudo ufw allow 11211/tcp
sudo ufw reload

# Configure Memcached to allow connections from any interface (instead of just localhost)
sudo sed -i 's/-l 127.0.0.1/-l 0.0.0.0/' /etc/memcached.conf
sudo systemctl restart memcached

# Run memcached as a daemon, with TCP port 11211 and UDP port 11111
sudo memcached -p 11211 -U 11111 -u memcached -d