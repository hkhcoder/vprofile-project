#!/bin/bash

# Update the package list
sudo apt update

# Install necessary packages: git, zip, unzip, and MariaDB server
sudo apt install git zip unzip mariadb-server -y

# Start and enable MariaDB service
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Clone the GitHub repository
cd /tmp/
git clone -b main https://github.com/hkhcoder/vprofile-project.git

# Set the MySQL root password
DATABASE_PASS='admin123'
sudo mysqladmin -u root password "$DATABASE_PASS"

# Run MySQL commands to secure the database and set privileges
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User=''"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"
sudo mysql -u root -p"$DATABASE_PASS" -e "create database accounts"
sudo mysql -u root -p"$DATABASE_PASS" -e "grant all privileges on accounts.* TO 'admin'@'localhost' identified by 'admin123'"
sudo mysql -u root -p"$DATABASE_PASS" -e "grant all privileges on accounts.* TO 'admin'@'%' identified by 'admin123'"

# Restore the database dump file
sudo mysql -u root -p"$DATABASE_PASS" accounts < /tmp/vprofile-project/src/main/resources/db_backup.sql

# Flush privileges and restart MariaDB
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"
sudo systemctl restart mariadb

# Disable firewall (this is not recommended for production environments; instead, configure the firewall to allow specific traffic)
sudo ufw disable