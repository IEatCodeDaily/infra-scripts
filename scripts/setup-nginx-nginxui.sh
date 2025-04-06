#!/bin/bash

# Script to update system, install NGINX, and install NGINX UI using the official installer
# This script runs inside an LXC container

set -e  # Exit on error

echo "===== Starting setup ====="

echo "===== Updating system packages ====="
apt update && apt upgrade -y

echo "===== Installing NGINX ====="
apt install -y nginx

echo "===== Enabling and starting NGINX service ====="
systemctl enable nginx && systemctl start nginx

echo "===== Installing prerequisites ====="
apt install -y curl

echo "===== Installing NGINX UI using the official installer ====="
bash -c "$(curl -L https://raw.githubusercontent.com/0xJacky/nginx-ui/main/install.sh)" @ install

# Get the IP address
IP_ADDRESS=$(ip -4 addr show scope global | grep inet | awk '{print $2}' | cut -d'/' -f1 | head -n 1)

echo "===== Setup completed successfully! ====="
echo "NGINX is running on $IP_ADDRESS:80"
echo "NGINX UI is running on $IP_ADDRESS:9000"
echo "Default NGINX UI credentials will be displayed on first login"
echo "You may need to configure firewall rules to access these ports from your network"
