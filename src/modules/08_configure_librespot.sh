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
render "$CONFIGS_DIR/librespot/librespot.service.tmpl" \
  > /etc/systemd/system/librespot.service


mkdir -p /etc/systemd/system/librespot.service.d
render "$CONFIGS_DIR/librespot/override.tmpl" \
  > /etc/systemd/system/librespot.service.d/override.conf

# Variables for the template are already defined in common.sh
# DEVICE_NAME, BITRATE, and VOLUME are used for the service configuration

# Render the template and write to the override file
render "$CONFIGS_DIR/librespot/librespot.service.override.conf.tmpl" > /etc/systemd/system/librespot.service.d/override.conf

# Enable and start librespot service
echo "Reloading systemd daemon"
systemctl daemon-reload

echo "Enabling librespot service"
sudo -u "$TARGET_USER" systemctl --user enable --now librespot || {
    echo "ERROR: Failed to enable librespot service"
    echo "Checking if service file exists:"
    ls -la /etc/systemd/system/librespot.service
    echo "Checking service status:"
    sudo -u "$TARGET_USER" systemctl --user status librespot || true
    exit 1
}

echo "Starting librespot service"
sudo -u "$TARGET_USER" systemctl --user restart librespot || {
    echo "ERROR: Failed to start librespot service"
    echo "Checking service logs:"
    sudo -u "$TARGET_USER" journalctl -u librespot --no-pager -n 20 || true
    exit 1
}