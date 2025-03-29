#!/bin/bash

# Script to configure a Debian-based system to use an existing apt-cacher
# Default apt-cacher IP is 192.168.1.254, but allows for custom IP

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" 
    exit 1
fi

# Check if curl is installed, install it if not
echo "Checking if curl is installed..."
if ! command -v curl &> /dev/null; then
    echo "curl not found. Installing curl..."
    apt-get update
    apt-get install -y curl
    if ! command -v curl &> /dev/null; then
        echo "Failed to install curl. Continuing without connection test..."
        CURL_INSTALLED=false
    else
        echo "curl installed successfully."
        CURL_INSTALLED=true
    fi
else
    echo "curl is already installed."
    CURL_INSTALLED=true
fi

# Default IP address of the apt-cacher server
DEFAULT_IP="192.168.1.254"
PROXY_IP=$DEFAULT_IP

# Ask user if they want to use the default IP or specify a custom one
echo "Default apt-cacher server IP is: $DEFAULT_IP"
read -p "Do you want to use this IP? (y/n): " USE_DEFAULT

if [ "$USE_DEFAULT" = "n" ] || [ "$USE_DEFAULT" = "N" ]; then
    read -p "Enter the IP address of your apt-cacher server: " CUSTOM_IP
    # Basic IP validation
    if [[ $CUSTOM_IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        PROXY_IP=$CUSTOM_IP
    else
        echo "Invalid IP format. Using default: $DEFAULT_IP"
    fi
fi

# Create apt configuration file for the proxy
echo "Setting up apt to use cache server at $PROXY_IP:3142..."

# Create the proxy configuration file
cat > /etc/apt/apt.conf.d/01proxy << EOF
Acquire::http::Proxy "http://$PROXY_IP:3142";
EOF

echo "Testing connection to apt-cacher..."
if [ "$CURL_INSTALLED" = true ]; then
    if curl -s --connect-timeout 5 http://$PROXY_IP:3142 > /dev/null; then
        echo "Connection to apt-cacher successful!"
    else
        echo "Warning: Could not connect to apt-cacher at $PROXY_IP:3142"
        echo "Please check if the server is running and accessible."
        echo "The proxy configuration has been set up, but may not work until the server is reachable."
    fi
else
    echo "Skipping connection test as curl is not available."
    echo "Please verify manually that the apt-cacher at $PROXY_IP:3142 is accessible."
fi

echo ""
echo "================================================"
echo "apt client has been configured to use apt-cacher!"
echo "Proxy server: $PROXY_IP:3142"
echo ""
echo "You can test it by running:"
echo "apt-get update"
echo ""
echo "To temporarily disable the proxy, rename or remove:"
echo "/etc/apt/apt.conf.d/01proxy"
echo "================================================"
