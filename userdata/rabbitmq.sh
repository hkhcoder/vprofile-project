#!/bin/bash
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | sudo bash
sudo yum makecache -y --disablerepo='*' --enablerepo='rabbitmq_rabbitmq-server'
sudo yum -y install rabbitmq-server
rpm -qi rabbitmq-server 
systemctl start rabbitmq-server
systemctl enable rabbitmq-server
sudo sh -c 'echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config'
sudo rabbitmqctl add_user test test
sudo rabbitmqctl set_user_tags test administrator
sudo systemctl restart rabbitmq-server
sudo yum install firewalld -y
sudo systemctl start firewalld
sudo systemctl enable firewalld
firewall-cmd --add-port=5672/tcp
firewall-cmd --runtime-to-permanent
