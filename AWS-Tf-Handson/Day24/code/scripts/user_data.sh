#!/bin/bash

# Update the package repository
apt-get update -y

# Install Docker
apt-get install -y docker.io

# Start and enable Docker service
systemctl start docker
systemctl enable docker

# Add ubuntu user to docker group (optional, but good practice)
usermod -aG docker ubuntu

# Pull and run the Django application container
# Mapping Host Port 80 (ALB traffic) to Container Port 8000 (Django default)
docker run -d \
  --name django-app \
  --restart always \
  -p 80:8000 \
  itsbaivab/django-app