#!/bin/bash
# Configure Snapclient for DietPi audio system
# This script sets up Snapcast client (no host avahi/mdns)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
CONFIG_DIR="$PROJECT_ROOT/config"

echo "Configuring Snapcast client..."

# Install Snapclient if not already installed
apt-get install -y snapclient

# Create Snapclient configuration directory
mkdir -p /etc/snapclient

# Copy Snapclient configuration file
cp "$PROJECT_ROOT/src/configurations/snapclient/snapclient.conf" /etc/default/snapclient

# Copy the configuration script to the config directory
cp "$PROJECT_ROOT/src/configurations/snapclient/snapclient_config.sh" "$CONFIG_DIR/snapclient_config.sh"

# Make the configuration script executable
chmod +x "$CONFIG_DIR/snapclient_config.sh"

# Create a service to ensure Snapclient always uses our ALSA device
mkdir -p /etc/systemd/system/snapclient.service.d
cp "$PROJECT_ROOT/src/configurations/snapclient/snapclient.service.override.conf" /etc/systemd/system/snapclient.service.d/override.conf

# Enable and start Snapclient service
systemctl daemon-reload
systemctl enable snapclient
systemctl restart snapclient

echo "Snapclient configuration complete."
echo "To configure the Snapserver IP, run: $CONFIG_DIR/snapclient_config.sh <snapserver_ip>"
