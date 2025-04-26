#!/bin/bash
# Configure Snapclient for DietPi audio system
# This script sets up Snapcast client (no host avahi/mdns)

# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

echo "Configuring Snapcast client..."

# Create a service override directory
mkdir -p /etc/systemd/system/snapclient.service.d
cp "$CONFIGS_DIR/snapclient/snapclient.service.override.conf" /etc/systemd/system/snapclient.service.d/override.conf

# Enable and start Snapclient service
systemctl daemon-reload
systemctl enable snapclient
systemctl restart snapclient

echo "Snapclient configuration complete."
