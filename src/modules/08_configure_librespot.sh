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

# Check if librespot binary exists, if not download a pre-built one
if [ ! -f "/usr/local/bin/librespot" ]; then
    log_message "librespot binary not found, downloading pre-built binary..."
    # Create a temporary directory
    TMP_DIR=$(mktemp -d)
    cd "$TMP_DIR"
    
    # Download a pre-built binary for ARM
    wget -O librespot.tar.gz https://github.com/librespot-org/librespot/releases/download/v0.4.2/librespot-v0.4.2-unknown-linux-armhf-with-alsa-bindings.tar.gz
    tar -xzf librespot.tar.gz
    
    # Install the binary
    cp librespot /usr/local/bin/
    chmod +x /usr/local/bin/librespot
    
    # Clean up
    cd - > /dev/null
    rm -rf "$TMP_DIR"
    
    log_message "Pre-built librespot binary installed"
fi

# Enable and start librespot service
log_message "Reloading systemd daemon"
systemctl daemon-reload

log_message "Enabling librespot service"
systemctl enable --now librespot
systemctl restart librespot

# Check if service started successfully
if ! systemctl is-active --quiet librespot; then
    log_message "Warning: librespot service failed to start. Check logs for details:"
    journalctl -u librespot -n 20
else
    log_message "librespot service started successfully"
fi