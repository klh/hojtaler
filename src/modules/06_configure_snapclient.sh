#!/bin/bash
# Configure Snapclient for DietPi audio system
# This script sets up Snapcast client (no host avahi/mdns)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
CONFIG_DIR="$PROJECT_ROOT/config"

# Determine the real user (the one who ran sudo)
if [ -n "$SUDO_USER" ]; then
    REAL_USER="$SUDO_USER"
else
    REAL_USER="$(whoami)"
fi

echo "Configuring Snapcast client..."

# Create Snapclient configuration directory
mkdir -p /etc/snapclient

# Copy Snapclient configuration file
cp "$PROJECT_ROOT/src/configurations/snapclient/snapclient.conf" /etc/default/snapclient

# Create config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Copy the configuration script to the config directory
cp "$PROJECT_ROOT/src/configurations/snapclient/snapclient_config.sh" "$CONFIG_DIR/snapclient_config.sh"

# Make the configuration script executable and set correct ownership
chmod +x "$CONFIG_DIR/snapclient_config.sh"
chown "$REAL_USER:$REAL_USER" "$CONFIG_DIR/snapclient_config.sh"

# Create a service to ensure Snapclient always uses our ALSA device
mkdir -p /etc/systemd/system/snapclient.service.d
cp "$PROJECT_ROOT/src/configurations/snapclient/snapclient.service.override.conf" /etc/systemd/system/snapclient.service.d/override.conf

# Enable and start Snapclient service
systemctl daemon-reload
systemctl enable snapclient
systemctl restart snapclient

echo "Snapclient configuration complete."
echo "To configure the Snapserver IP, run: $CONFIG_DIR/snapclient_config.sh <snapserver_ip>"
