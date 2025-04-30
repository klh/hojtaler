#!/bin/bash
# Configure Snapclient for DietPi audio system
# This script sets up Snapcast client (no host avahi/mdns)

# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

log_message "Configuring Snapcast client..."

# Create a service override directory
mkdir -p /etc/systemd/system/snapclient.service.d
render "$CONFIGS_DIR/snapclient/snapclient.service.override.conf.tmpl" > /etc/systemd/system/snapclient.service.d/override.conf

# Enable and start Snapclient service
systemctl daemon-reload
systemctl enable snapclient
systemctl restart snapclient

log_message "✅ Snapclient configuration complete."