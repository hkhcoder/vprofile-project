#!/bin/bash
DATABASE_PASS='admin123'

# Update and install dependencies
sudo apt update -y

# Memcached
sudo apt install memcached -y
sudo systemctl start memcached
sudo systemctl enable memcached

# RabbitMQ
sudo apt install -y curl gnupg apt-transport-https
curl -fsSL https://packagecloud.io/rabbitmq/rabbitmq-server/gpgkey | sudo apt-key add -
sudo apt-key adv --keyserver "hkps://keyserver.ubuntu.com:443" --recv-keys F7B8CEA6056E8E56
sudo tee /etc/apt/sources.list.d/rabbitmq.list <<EOF
deb https://packagecloud.io/rabbitmq/rabbitmq-server/ubuntu/ focal main
EOF
sudo apt update -y
sudo apt install rabbitmq-server -y
sudo systemctl start rabbitmq-server
sudo systemctl enable rabbitmq-server
echo "[{rabbit, [{loopback_users, []}]}]." | sudo tee /etc/rabbitmq/rabbitmq.config
sudo rabbitmqctl add_user rabbit bunny
sudo rabbitmqctl set_user_tags rabbit administrator
sudo systemctl restart rabbitmq-server

# MariaDB (MySQL)
sudo apt install mariadb-server -y

# Secure MariaDB installation
sudo sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

# Starting & enabling MariaDB server
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Secure MariaDB
sudo mysqladmin -u root password "$DATABASE_PASS"
sudo mysql -u root -p"$DATABASE_PASS" -e "UPDATE mysql.user SET Password=PASSWORD('$DATABASE_PASS') WHERE User='root'"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User=''"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"
sudo mysql -u root -p"$DATABASE_PASS" -e "create database accounts"
sudo mysql -u root -p"$DATABASE_PASS" -e "grant all privileges on accounts.* TO 'admin'@'localhost' identified by 'admin123'"
sudo mysql -u root -p"$DATABASE_PASS" -e "grant all privileges on accounts.* TO 'admin'@'app01' identified by 'admin123'"
sudo mysql -u root -p"$DATABASE_PASS" accounts < /vagrant/vprofile-repo/src/main/resources/db_backup.sql
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"

# Restart MariaDB
sudo systemctl restart mariadb