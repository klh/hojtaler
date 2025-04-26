#!/bin/bash
# Configure Snapclient for DietPi audio system
# This script sets up Snapcast client (no host avahi/mdns)

# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

echo "Configuring Snapcast client..."

# Create Snapclient configuration directory
mkdir -p /etc/snapclient

# Render Snapclient configuration from template
# Variables for the template are already defined in common.sh
# HZ, BITS, and CHANNELS are used for the audio configuration

# Render the template and write to the configuration file
render "$CONFIGS_DIR/snapclient/snapclient.conf.tmpl" > /etc/default/snapclient

# Create config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Copy the configuration script to the config directory
cp "$CONFIGS_DIR/snapclient/snapclient_config.sh" "$CONFIG_DIR/snapclient_config.sh"

# Make the configuration script executable and set correct ownership
chmod +x "$CONFIG_DIR/snapclient_config.sh"
chown "$REAL_USER:$REAL_USER" "$CONFIG_DIR/snapclient_config.sh"

# Create a service override directory
mkdir -p /etc/systemd/system/snapclient.service.d
cp "$CONFIGS_DIR/snapclient/snapclient.service.override.conf" /etc/systemd/system/snapclient.service.d/override.conf

# Enable and start Snapclient service
systemctl daemon-reload
systemctl enable snapclient
systemctl restart snapclient

echo "Snapclient configuration complete."
echo "To configure the Snapserver IP, run: $CONFIG_DIR/snapclient_config.sh <snapserver_ip>"
