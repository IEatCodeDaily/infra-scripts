#!/bin/bash

# Update the system
sudo zypper refresh
sudo zypper update -y

# Install Docker
sudo zypper install -y docker

# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add current user to docker group (optional, for convenience)
sudo usermod -aG docker $USER

# Install Rancher (single-node setup)
sudo docker run -d --restart=unless-stopped -p 80:80 -p 443:443 --privileged rancher/rancher:latest

# Print the Rancher URL
echo "Rancher is now running. Access it at https://$(curl -s ifconfig.me)"
echo "Please ensure ports 80 and 443 are open in your firewall."

# Open necessary ports in the firewall
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --reload

echo "Firewall has been configured to allow access to Rancher."
echo "You may need to log out and back in for group changes to take effect."