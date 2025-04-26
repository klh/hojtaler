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


# Set CPU governor to performance for better audio
echo "Setting CPU governor to performance..."
echo 'GOVERNOR=performance' > /etc/default/cpufrequtils

echo "System preparation complete."
