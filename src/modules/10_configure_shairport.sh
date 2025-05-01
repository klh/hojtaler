#!/bin/bash
# Configure Shairport-Sync for  audio system
# This script sets up AirPlay functionality

# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"
log_message "Configuring Shairport-Sync (AirPlay)..."

# Shairport-Sync is already installed by 02_install_deps.sh
log_message "Configuring Shairport-Sync..."

# Backup original configuration
if [ -f /etc/shairport-sync.conf ]; then
    cp /etc/shairport-sync.conf /etc/shairport-sync.conf.bak
fi

# Copy shairport-sync configuration
render "$CONFIGS_DIR/shairport/shairport-sync.conf.tmpl" > /etc/shairport-sync.conf

# Create service override directory and copy the override file
mkdir -p /etc/systemd/system/shairport-sync.service.d

# Copy shairport-sync service override
render "$CONFIGS_DIR/shairport/shairport-sync.service.override.conf.tmpl" > /etc/systemd/system/shairport-sync.service.d/override.conf

# Enable and start shairport-sync service
systemctl daemon-reload
systemctl enable shairport-sync
systemctl restart shairport-sync

log_message "✅ Shairport-Sync with AirPlay 2 support has been built and installed successfully."
