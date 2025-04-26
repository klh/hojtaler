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
render "$CONFIGS_DIR/librespot/librespot.service.tmpl" > /etc/systemd/system/librespot.service

# Verify the service file was copied successfully
if [ ! -f "/etc/systemd/system/librespot.service" ]; then
    echo "ERROR: Failed to copy librespot.service to /etc/systemd/system/"
    exit 1
fi

echo "librespot.service file installed successfully"

# Create librespot service configuration override directory
mkdir -p /etc/systemd/system/librespot.service.d

# Render the override configuration from template

# Variables for the template are already defined in common.sh
# DEVICE_NAME, BITRATE, and VOLUME are used for the service configuration

# Render the template and write to the override file
render "$CONFIGS_DIR/librespot/librespot.service.override.conf.tmpl" > /etc/systemd/system/librespot.service.d/override.conf

# Create config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Copy the configuration script to the config directory
cp "$CONFIGS_DIR/librespot/librespot_config.sh" "$CONFIG_DIR/librespot_config.sh"

# Make the configuration script executable and set correct ownership
chmod +x "$CONFIG_DIR/librespot_config.sh"
chown "$REAL_USER:$REAL_USER" "$CONFIG_DIR/librespot_config.sh"

# Enable and start librespot service
echo "Reloading systemd daemon"
systemctl daemon-reload

echo "Enabling librespot service"
systemctl enable librespot || {
    echo "ERROR: Failed to enable librespot service"
    echo "Checking if service file exists:"
    ls -la /etc/systemd/system/librespot.service
    echo "Checking service status:"
    systemctl status librespot || true
    exit 1
}

echo "Starting librespot service"
systemctl restart librespot || {
    echo "ERROR: Failed to start librespot service"
    echo "Checking service logs:"
    journalctl -u librespot --no-pager -n 20 || true
    exit 1
}

echo "librespot configuration complete."
echo "To customize librespot settings, run: $CONFIG_DIR/librespot_config.sh [options]"
echo "Example: $CONFIG_DIR/librespot_config.sh --name \"Living Room\" --bitrate 320 --volume 80"
