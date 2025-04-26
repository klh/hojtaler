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
systemctl daemon-reload

echo "Enabling librespot service"
sudo -iu "$TARGET_USER" bash -c 'systemctl --user daemon-reload systemctl --user enable --now librespot' || {
    echo "ERROR: Failed to enable librespot service"
    echo "Checking if service file exists:"
    ls -la /etc/systemd/system/librespot.service
    echo "Checking service status:"
    sudo -iu "$TARGET_USER" systemctl --user status librespot || true
    exit 1
}

echo "Starting librespot service"
sudo -iu "$TARGET_USER" systemctl --user restart librespot || {
    echo "ERROR: Failed to start librespot service"
    echo "Checking service logs:"
    sudo -iu "$TARGET_USER" journalctl -u librespot --no-pager -n 20 || true
    exit 1
}