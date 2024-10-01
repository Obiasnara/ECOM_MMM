#!/bin/bash

# Update and install necessary packages
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the stable repository for Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Enable Docker service to start on boot
sudo systemctl enable docker
sudo systemctl start docker

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Create directory for Docker Compose files
sudo mkdir -p /opt/docker-compose
sudo chown -R $USER:$USER /opt/docker-compose

# Create a directory for the compose file
mkdir -p /home/adminuser/app

cat <<EOF > /home/adminuser/app/docker-compose.yml
# This configuration is intended for development purpose, it's **your** responsibility to harden it for production
name: job
services:
  app:
    image: obiasnara/mmm_repo:latest
    environment:
      - _JAVA_OPTIONS=-Xmx512m -Xms256m
      - SPRING_PROFILES_ACTIVE=prod,api-docs
      - MANAGEMENT_PROMETHEUS_METRICS_EXPORT_ENABLED=true
      - SPRING_DATASOURCE_URL=jdbc:postgresql://postgresql:5432/job
      - SPRING_LIQUIBASE_URL=jdbc:postgresql://postgresql:5432/job
    ports:
      - 127.0.0.1:8080:8080
    healthcheck:
      test:
        - CMD
        - curl
        - -f
        - http://localhost:8080/management/health
      interval: 5s
      timeout: 5s
      retries: 40
    # Based on dockerfile

    depends_on:
      postgresql:
        condition: service_healthy
  postgresql:
    extends:
      file: ./postgresql.yml
      service: postgresql
EOF 

# Start the application
cd /home/adminuser/app
docker-compose up -d
