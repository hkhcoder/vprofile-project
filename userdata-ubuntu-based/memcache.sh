#!/bin/bash
sudo apt update -y
sudo apt install epel-release -y
sudo apt install memcached -y
sudo systemctl start memcached
sudo systemctl enable memcached
sudo systemctl status memcached
sudo sed -i 's/127.0.0.1/0.0.0.0/g' /etc/memcached.conf
sudo systemctl restart memcached
sudo memcached -p 11211 -U 11111 -u memcache -d
