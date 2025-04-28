#!/bin/bash
# Configure librespot for DietPi audio system
# This script sets up Spotify Connect functionality

# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

log_message "Configuring librespot (Spotify Connect)..."

# Install the base librespot service file using the template
log_message "Installing librespot service file to /etc/systemd/system/"

# Variables for the template are already defined in common.sh
# DEVICE_NAME is used for the service configuration

# Render the template and write to the service file
mkdir -p /etc/systemd/system/librespot.service.d

render "$CONFIGS_DIR/librespot/librespot.service.tmpl" \
  > /etc/systemd/system/librespot.service.d/override.conf

# Enable and start librespot service
log_message "Reloading systemd daemon"
 systemctl daemon-reload

log_message "Enabling librespot service"
systemctl  enable --now librespot
systemctl restart librespot
journalctl  librespot -n 20