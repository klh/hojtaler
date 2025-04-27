#!/bin/bash
# Configure Shairport-Sync for DietPi audio system
# This script sets up AirPlay functionality

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
CONFIG_DIR="$PROJECT_ROOT/config"

echo "Configuring Shairport-Sync (AirPlay)..."

# Install Shairport-Sync if not already installed
apt-get install -y shairport-sync

# Backup original configuration
if [ -f /etc/shairport-sync.conf ]; then
    cp /etc/shairport-sync.conf /etc/shairport-sync.conf.bak
fi

# Copy Shairport-Sync configuration from project directory
cp "$PROJECT_ROOT/src/configurations/shairport/shairport-sync.conf" /etc/shairport-sync.conf

# Update the device name to Cloudspeaker if needed
sed -i 's/name = ".*";/name = "Cloudspeaker";/g' /etc/shairport-sync.conf
sed -i 's/airplay_device_id = ".*";/airplay_device_id = "Cloudspeaker";/g' /etc/shairport-sync.conf

# Copy the configuration script for customizing Shairport-Sync settings
cp "$PROJECT_ROOT/src/configurations/shairport/shairport_config.sh" "$CONFIG_DIR/shairport_config.sh"

# Make the configuration script executable
chmod +x "$CONFIG_DIR/shairport_config.sh"

# Enable and start Shairport-Sync service
systemctl daemon-reload
systemctl enable shairport-sync
systemctl restart shairport-sync

echo "Shairport-Sync configuration complete."
echo "To customize Shairport-Sync settings, run: $CONFIG_DIR/shairport_config.sh [options]"
echo "Example: $CONFIG_DIR/shairport_config.sh --name \"Living Room\" --volume-range 70"
