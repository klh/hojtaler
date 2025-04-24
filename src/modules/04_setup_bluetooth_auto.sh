#!/bin/bash
# Setup Bluetooth with auto-accept for DietPi audio system
# This script configures Bluetooth to automatically accept connections

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
CONFIG_DIR="$PROJECT_ROOT/config"

echo "Setting up Bluetooth with auto-accept functionality..."

# Install Bluetooth packages if not already installed
apt-get install -y bluez bluez-alsa-utils bluealsa python3-dbus python3-gi

# Enable Bluetooth service
systemctl enable bluetooth
systemctl start bluetooth

# Configure Bluetooth settings with SSP (Simple Secure Pairing) disabled
cp "$PROJECT_ROOT/src/configurations/bluetooth/bluetooth-main.conf" /etc/bluetooth/main.conf

# Set Bluetooth to automatically accept connections
# Add pairable and discoverable settings to main.conf
sed -i '/\[General\]/a DiscoverableTimeout = 0\nPairableTimeout = 0\nAlwaysPairable = true' /etc/bluetooth/main.conf

# Create BlueALSA configuration
mkdir -p /etc/bluealsa
cp "$PROJECT_ROOT/src/configurations/bluetooth/bluealsa.conf" /etc/bluealsa/bluealsa.conf

# Create BlueALSA service override
mkdir -p /etc/systemd/system/bluealsa.service.d
cp "$PROJECT_ROOT/src/configurations/bluetooth/bluealsa.service.override.conf" /etc/systemd/system/bluealsa.service.d/override.conf

# Copy the auto-accept agent script to system location
cp "$PROJECT_ROOT/src/configurations/bluetooth/bluetooth-autoaccept.py" /usr/local/bin/
chmod +x /usr/local/bin/bluetooth-autoaccept.py

# Create auto-accept service
cp "$PROJECT_ROOT/src/configurations/bluetooth/bluetooth-autoaccept.service" /etc/systemd/system/

# Create a service to automatically connect to known devices
cp "$PROJECT_ROOT/src/configurations/bluetooth/bluetooth-autoconnect.service" /etc/systemd/system/bluetooth-autoconnect.service

# Create a service to route Bluetooth audio to our ALSA device
cp "$PROJECT_ROOT/src/configurations/bluetooth/bluealsa-aplay.service" /etc/systemd/system/bluealsa-aplay.service

# Enable and start services
systemctl daemon-reload
systemctl enable bluetooth-autoconnect.service
systemctl enable bluetooth-autoaccept.service
systemctl enable bluealsa.service
systemctl enable bluealsa-aplay.service

systemctl start bluetooth-autoconnect.service
systemctl start bluetooth-autoaccept.service
systemctl start bluealsa.service
systemctl start bluealsa-aplay.service

# Configure Bluetooth to be permanently discoverable and pairable
bluetoothctl -- power on
bluetoothctl -- discoverable on
bluetoothctl -- pairable on
bluetoothctl -- agent NoInputNoOutput
bluetoothctl -- default-agent

echo "Bluetooth auto-accept setup complete."
echo "Any device should now be able to connect without manual pairing."
