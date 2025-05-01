#!/bin/bash
# Setup Bluetooth audio with auto-accept for PI audio system
# This script configures Bluetooth to automatically accept connections

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
CONFIG_DIR="$PROJECT_ROOT/config"

# Determine the real user (the one who ran sudo)
if [ -n "${SUDO_USER:-}" ]; then
    REAL_USER="$SUDO_USER"
else
    REAL_USER="$(whoami)"
fi

echo "1) Installing Bluetooth packages..."
apt-get update
apt-get install -y bluez bluez-alsa-utils alsa-utils swh-plugins

echo "2) Enabling and starting Bluetooth + BlueZ-ALSA..."
systemctl enable bluetooth.service bluealsa.service
systemctl start bluetooth.service bluealsa.service

echo "3) Making Bluetooth forever discoverable & pairable..."
mkdir -p /etc/bluetooth

# Copy main.conf with proper settings
cp "$PROJECT_ROOT/src/configurations/bluetooth/bluetooth-main.conf" /etc/bluetooth/main.conf

# Update the device name to Cloudspeaker if needed
sed -i 's/Name =.*/Name = Cloudspeaker/g' /etc/bluetooth/main.conf

echo "4) Installing zero-pin pairing agent..."

# Copy bt-agent.service for zero-pin pairing
cp "$PROJECT_ROOT/src/configurations/bluetooth/bt-agent.service" /etc/systemd/system/

systemctl daemon-reload
systemctl enable bt-agent.service
systemctl start bt-agent.service

# Configure Bluetooth to be discoverable and pairable
bluetoothctl -- power on
bluetoothctl -- discoverable on
bluetoothctl -- pairable on

echo "Bluetooth auto-accept setup complete."
echo "Your Raspberry Pi will:"
echo " • stay discoverable/pairable forever"
echo " • auto-accept any pairing without PIN"
echo " • expose each A2DP stream as an ALSA PCM via bluez-alsa"
echo 
echo "The A2DP streams will be automatically routed through your ALSA configuration"
echo "with the optimal settings for your HiFiBerry AMP4 (S32 at 44100Hz)."
