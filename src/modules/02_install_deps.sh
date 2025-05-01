#!/bin/bash
# Install dependencies for DietPi audio system
# This script installs all required packages and software


# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

# Install all packages in a single command for speed
PACKAGE_COUNT=$(echo $ALL_PACKAGES | wc -w)
log_message "Installing $PACKAGE_COUNT dependencies..."
install_packages $ALL_PACKAGES

# Enable and start required services
log_message "Enabling and starting Avahi daemon for mDNS..."
systemctl enable avahi-daemon
systemctl start avahi-daemon

log_message "Enabling and starting Chrony accurate timesync..."
systemctl disable --now systemd-timesyncd
systemctl enable --now chrony


log_message "✅ All dependencies installed successfully."
