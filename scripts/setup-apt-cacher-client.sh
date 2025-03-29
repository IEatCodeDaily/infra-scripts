#!/bin/bash

# Script to configure a Debian-based system to use an existing apt-cacher
# Default apt-cacher IP is 192.168.1.254, but allows for custom IP

# Define colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Function for success messages
success() {
  echo -e "${GREEN}${BOLD}[SUCCESS]${NC} $1"
}

# Function for error messages
error() {
  echo -e "${RED}${BOLD}[ERROR]${NC} $1"
}

# Function for warning messages
warning() {
  echo -e "${YELLOW}${BOLD}[WARNING]${NC} $1"
}

# Function for info messages
info() {
  echo -e "${BLUE}${BOLD}[INFO]${NC} $1"
}

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    error "This script must be run as root"
    exit 1
fi

# Check if curl is installed, install it if not
info "Checking if curl is installed..."
if ! command -v curl &> /dev/null; then
    warning "curl not found. Installing curl..."
    apt-get update
    apt-get install -y curl
    if ! command -v curl &> /dev/null; then
        error "Failed to install curl. Continuing without connection test..."
        CURL_INSTALLED=false
    else
        success "curl installed successfully."
        CURL_INSTALLED=true
    fi
else
    info "curl is already installed."
    CURL_INSTALLED=true
fi

# Default IP address of the apt-cacher server
DEFAULT_IP="192.168.1.254"
PROXY_IP=$DEFAULT_IP

# Ask user if they want to use the default IP or specify a custom one
echo -e "${BLUE}${BOLD}Default apt-cacher server IP is:${NC} $DEFAULT_IP"
read -p "$(echo -e ${YELLOW}"Do you want to use this IP? (y/n): "${NC})" USE_DEFAULT

if [ "$USE_DEFAULT" = "n" ] || [ "$USE_DEFAULT" = "N" ]; then
    read -p "$(echo -e ${BLUE}"Enter the IP address of your apt-cacher server: "${NC})" CUSTOM_IP
    # Basic IP validation
    if [[ $CUSTOM_IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        PROXY_IP=$CUSTOM_IP
        info "Using custom IP: $PROXY_IP"
    else
        warning "Invalid IP format. Using default: $DEFAULT_IP"
    fi
fi

# Create apt configuration file for the proxy
info "Setting up apt to use cache server at ${BOLD}$PROXY_IP:3142${NC}..."

# Create the proxy configuration file
cat > /etc/apt/apt.conf.d/01proxy << EOF
Acquire::http::Proxy "http://$PROXY_IP:3142";
EOF

info "Testing connection to apt-cacher..."
if [ "$CURL_INSTALLED" = true ]; then
    if curl -s --connect-timeout 5 http://$PROXY_IP:3142 > /dev/null; then
        success "Connection to apt-cacher successful!"
    else
        warning "Could not connect to apt-cacher at $PROXY_IP:3142"
        warning "Please check if the server is running and accessible."
        warning "The proxy configuration has been set up, but may not work until the server is reachable."
    fi
else
    warning "Skipping connection test as curl is not available."
    warning "Please verify manually that the apt-cacher at $PROXY_IP:3142 is accessible."
fi

echo ""
echo -e "${BOLD}================================================${NC}"
success "apt client has been configured to use apt-cacher!"
echo -e "${BOLD}Proxy server:${NC} $PROXY_IP:3142"
echo ""
info "You can test it by running:"
echo -e "${BLUE}apt-get update${NC}"
echo ""
info "To temporarily disable the proxy, rename or remove:"
echo -e "${BLUE}/etc/apt/apt.conf.d/01proxy${NC}"
echo -e "${BOLD}================================================${NC}"
