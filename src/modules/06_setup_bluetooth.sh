#!/bin/bash
# Setup Bluetooth audio for DietPi audio system
# This script configures BlueALSA for A2DP audio streaming

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
CONFIG_DIR="$PROJECT_ROOT/config"

echo "Setting up Bluetooth audio..."

# Install Bluetooth packages if not already installed
apt-get install -y bluez bluez-alsa-utils bluealsa python3-dbus

# Enable Bluetooth service
systemctl enable bluetooth
systemctl start bluetooth

# Configure Bluetooth settings
cp "$PROJECT_ROOT/src/configurations/bluetooth/bluetooth-main.conf" /etc/bluetooth/main.conf

# Create BlueALSA configuration
mkdir -p /etc/bluealsa
cp "$PROJECT_ROOT/src/configurations/bluetooth/bluealsa.conf" /etc/bluealsa/bluealsa.conf

# Create BlueALSA service override
mkdir -p /etc/systemd/system/bluealsa.service.d
cp "$PROJECT_ROOT/src/configurations/bluetooth/bluealsa.service.override.conf" /etc/systemd/system/bluealsa.service.d/override.conf

# Create a service to automatically connect to known devices
cp "$PROJECT_ROOT/src/configurations/bluetooth/bluetooth-autoconnect.service" /etc/systemd/system/bluetooth-autoconnect.service

# Copy the Bluetooth pairing script to the config directory
cp "$PROJECT_ROOT/src/configurations/bluetooth/pair_bluetooth.sh" "$CONFIG_DIR/pair_bluetooth.sh"

# Make the pairing script executable
chmod +x "$CONFIG_DIR/pair_bluetooth.sh"

# Create a service to route Bluetooth audio to our ALSA device
cp "$PROJECT_ROOT/src/configurations/bluetooth/bluealsa-aplay.service" /etc/systemd/system/bluealsa-aplay.service

# Enable and start services
systemctl daemon-reload
systemctl enable bluetooth-autoconnect.service
systemctl enable bluealsa.service
systemctl enable bluealsa-aplay.service

systemctl start bluetooth-autoconnect.service
systemctl start bluealsa.service
systemctl start bluealsa-aplay.service

echo "Bluetooth audio setup complete."
echo "To pair a new device, run: $CONFIG_DIR/pair_bluetooth.sh"
