#!/bin/bash
# Install dependencies for DietPi audio system
# This script installs all required packages and software


# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

# Install all packages in a single command for speed
PACKAGE_COUNT=$(echo $ALL_PACKAGES | wc -w)
echo "Installing $PACKAGE_COUNT dependencies..."
install_packages $ALL_PACKAGES

# Install Oh My Zsh for both users
echo "Installing Oh My Zsh..."

# For dietpi
sudo -u "$TARGET_USER" RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Set up zsh as default shell
echo "Setting up zsh as default shell..."
chsh -s $(which zsh) dietpi

# Enable and start required services
echo "Enabling and starting Avahi daemon for mDNS..."
systemctl enable avahi-daemon
systemctl start avahi-daemon

echo "All dependencies installed successfully."
