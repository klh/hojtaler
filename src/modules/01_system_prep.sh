#!/bin/bash
# System preparation for DietPi audio system
# This script prepares the base DietPi system for our audio setup


# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

echo "speeding up installation via apt"
cp "$CONFIGS_DIR/apt/99parallel" "/etc/apt/apt.conf.d/99parallel"

echo "Updating system packages..."
apt update
apt-get upgrade -qq > /dev/null

# Enable required modules
echo "Enabling required kernel modules..."
if ! grep -q "snd-bcm2835" /etc/modules; then
    echo "snd-bcm2835" >> /etc/modules
fi

echo "System preparation complete."

sudo usermod -aG audio "$TARGET_USER" 

echo "umasking"
systemctl unmask systemd-logind
systemctl enable --now systemd-logind
loginctl enable-linger "$TARGET_USER"
