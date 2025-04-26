#!/bin/bash
# Install dependencies for DietPi audio system
# This script installs all required packages and software


# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

# Install all packages in a single command for speed
PACKAGE_COUNT=$(echo $ALL_PACKAGES | wc -w)
echo "Installing $PACKAGE_COUNT dependencies..."
install_packages $ALL_PACKAGES

#ENABLE zsh
chsh -s $(which zsh) && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Enable linger for root and kk
loginctl enable-linger root
loginctl enable-linger kk
sudo -u kk systemctl --user enable --now pipewire pipewire-pulse wireplumber

# Enable and start required services
echo "Enabling and starting Avahi daemon for mDNS..."
systemctl enable avahi-daemon
systemctl start avahi-daemon

echo "All dependencies installed successfully."
