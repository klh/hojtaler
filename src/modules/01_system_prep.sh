#!/bin/bash
# System preparation for DietPi audio system
# This script prepares the base DietPi system for our audio setup

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
CONFIG_DIR="$PROJECT_ROOT/config"

echo "Updating system packages..."
apt-get update
apt-get upgrade -y

# Enable I2S for HiFiBerry
echo "Enabling I2S for HiFiBerry AMP4..."
if ! grep -q "dtoverlay=hifiberry-dacplus" /boot/config.txt; then
    echo "dtoverlay=hifiberry-dacplus" >> /boot/config.txt
    echo "dtparam=audio=on" >> /boot/config.txt
fi

# Disable onboard audio
if grep -q "dtparam=audio=on" /boot/config.txt && ! grep -q "#dtparam=audio=on" /boot/config.txt; then
    sed -i 's/dtparam=audio=on/#dtparam=audio=on/g' /boot/config.txt
fi

# Disable HDMI audio
if ! grep -q "hdmi_ignore_edid_audio=1" /boot/config.txt; then
    echo "hdmi_ignore_edid_audio=1" >> /boot/config.txt
fi

# Enable required modules
echo "Enabling required kernel modules..."
if ! grep -q "snd-bcm2835" /etc/modules; then
    echo "snd-bcm2835" >> /etc/modules
fi

# Create asound.conf if it doesn't exist
if [ ! -f /etc/asound.conf ]; then
    touch /etc/asound.conf
fi

# Set CPU governor to performance for better audio
echo "Setting CPU governor to performance..."
echo 'GOVERNOR=performance' > /etc/default/cpufrequtils

echo "System preparation complete."
