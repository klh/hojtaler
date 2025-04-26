#!/bin/bash
# Configure Shairport-Sync for DietPi audio system
# This script sets up AirPlay functionality

# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

echo "Configuring Shairport-Sync (AirPlay)..."

# Shairport-Sync is already installed by 02_install_deps.sh
log_message "Configuring Shairport-Sync..."

# Backup original configuration
if [ -f /etc/shairport-sync.conf ]; then
    cp /etc/shairport-sync.conf /etc/shairport-sync.conf.bak
fi

# Render Shairport-Sync configuration from template

# Variables for the template are already defined in common.sh
# DEVICE_NAME and VOLUME_RANGE are used for the configuration

# Render the template and write to the configuration file
render "$CONFIGS_DIR/shairport/shairport-sync.conf.tmpl" > /etc/shairport-sync.conf

# Copy the configuration script for customizing Shairport-Sync settings
cp "$CONFIGS_DIR/shairport/shairport_config.sh" "$CONFIG_DIR/shairport_config.sh"

# Make the configuration script executable
chmod +x "$CONFIG_DIR/shairport_config.sh"

# Enable and start Shairport-Sync service
systemctl daemon-reload
systemctl enable shairport-sync
systemctl restart shairport-sync

echo "Shairport-Sync configuration complete."
echo "To customize Shairport-Sync settings, run: $CONFIG_DIR/shairport_config.sh [options]"
echo "Example: $CONFIG_DIR/shairport_config.sh --name \"Living Room\" --volume-range 70"
