#!/bin/bash
# Configure librespot for DietPi audio system
# This script sets up Spotify Connect functionality

# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

echo "Configuring librespot (Spotify Connect)..."

# Install the base librespot service file using the template
echo "Installing librespot service file to /etc/systemd/system/"

# Variables for the template are already defined in common.sh
# DEVICE_NAME is used for the service configuration

# Render the template and write to the service file
mkdir -p /etc/systemd/user/librespot.service.d

render "$CONFIGS_DIR/librespot/librespot.service.tmpl" \
  > /etc/systemd/user/librespot.service

# Enable and start librespot service
echo "Reloading systemd daemon"
sudo -iu "$TARGET_USER" systemctl --user daemon-reload

echo "Enabling librespot service"
sudo -iu "$TARGET_USER" systemctl --user enable --now librespot
sudo -iu "$TARGET_USER" systemctl --user restart librespot
sudo -iu "$TARGET_USER" journalctl --user -u librespot -n 20