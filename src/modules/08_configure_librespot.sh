#!/bin/bash
# Configure librespot for DietPi audio system
# This script sets up Spotify Connect functionality

# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

log_message "Configuring librespot (Spotify Connect)..."

# Install the librespot service file using the template
log_message "Installing librespot service file to /lib/systemd/system/"

# Variables for the template are already defined in common.sh
# DEVICE_NAME, BITRATE, VOLUME, and HZ are used for the service configuration

# Create proper service file
render "$CONFIGS_DIR/librespot/librespot.service.tmpl" > /lib/systemd/system/librespot.service

# Make sure the service file has the correct permissions
chmod 644 /lib/systemd/system/librespot.service

# Remove any override files if they exist to prevent conflicts
if [ -d "/etc/systemd/system/librespot.service.d" ]; then
    log_message "Removing existing librespot service overrides"
    rm -rf /etc/systemd/system/librespot.service.d
fi

# Enable and start librespot service
log_message "Reloading systemd daemon"
 systemctl daemon-reload

log_message "Enabling librespot service"
systemctl enable --now librespot
systemctl restart librespot
journalctl  librespot -n 20