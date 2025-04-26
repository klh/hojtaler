#!/bin/bash
# Install dependencies for DietPi audio system
# This script installs all required packages and software


# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

# Enable linger for root and kk
loginctl enable-linger root
loginctl enable-linger kk
sudo -u kk systemctl --user enable --now pipewire pipewire-pulse wireplumber

# Install all packages in a single apt-get command for speed
echo "Installing dependencies..."
apt-get update
apt-get install -y --no-install-recommends $ALL_PACKAGES

# Enable and start required services
echo "Enabling and starting Avahi daemon for mDNS..."
systemctl enable avahi-daemon
systemctl start avahi-daemon

echo "All dependencies installed successfully."
