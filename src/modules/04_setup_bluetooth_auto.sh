#!/bin/bash
# Setup Bluetooth audio with auto-accept for DietPi audio system
# This script configures Bluetooth for PipeWire integration

set -euo pipefail

# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

log_message "Setting up Bluetooth for PipeWire integration"

# Step 1: Configure Bluetooth settings for discoverability and pairing
echo "1) Configuring Bluetooth settings..."
mkdir -p /etc/bluetooth

# Render Bluetooth configuration from template
render "$CONFIGS_DIR/bluetooth/bluetooth-main.conf.tmpl" > /etc/bluetooth/main.conf

# Step 2: Enable and start Bluetooth service
echo "2) Enabling and starting Bluetooth service..."
systemctl enable bluetooth.service
systemctl start bluetooth.service

# Step 3: Configure PipeWire Bluetooth integration
echo "3) Configuring PipeWire Bluetooth integration..."

# Ensure PipeWire config directories exist
mkdir -p /etc/pipewire/pipewire.conf.d
mkdir -p /etc/wireplumber/bluetooth.lua.d

# Render PipeWire Bluetooth configuration from template
render "$CONFIGS_DIR/bluetooth/20-bluetooth.conf.tmpl" > /etc/pipewire/pipewire.conf.d/20-bluetooth.conf

# Render WirePlumber Bluetooth configuration from template
render "$CONFIGS_DIR/bluetooth/51-bluez-config.lua.tmpl" > /etc/wireplumber/bluetooth.lua.d/51-bluez-config.lua

# Step 4: Install and configure auto-pairing agent
echo "4) Setting up zero-pin auto-pairing agent..."

# Render and install the agent service file
render "$CONFIGS_DIR/bluetooth/bt-agent.service.tmpl" > /etc/systemd/system/bt-agent.service

# Render and install the auto-connect script
render "$CONFIGS_DIR/bluetooth/bt-auto-connect.tmpl" > /usr/local/bin/bt-auto-connect

# Make the script executable
chmod +x /usr/local/bin/bt-auto-connect

# Render and install the auto-connect service
render "$CONFIGS_DIR/bluetooth/bt-auto-connect.service.tmpl" > /etc/systemd/system/bt-auto-connect.service

# Enable and start the services
systemctl daemon-reload
systemctl enable bt-agent.service bt-auto-connect.service
systemctl start bt-agent.service

# Step 5: Ensure PipeWire services are running for the user
echo "5) Ensuring PipeWire services are active..."

# Enable linger for the user to ensure services start at boot
loginctl enable-linger $USER

# Start PipeWire services for the user
sudo -u $USER systemctl --user daemon-reload
sudo -u $USER systemctl --user enable --now pipewire.service pipewire-pulse.service wireplumber.service

# Step 6: Configure Bluetooth controller
echo "6) Configuring Bluetooth controller..."

# Set Bluetooth controller to be always discoverable and pairable
bluetooth_controller=$(bluetoothctl list | head -n 1 | cut -d' ' -f2)
if [ -n "$bluetooth_controller" ]; then
  bluetoothctl -- power on
  bluetoothctl -- discoverable on
  bluetoothctl -- pairable on
  bluetoothctl -- agent NoInputNoOutput
  bluetoothctl -- default-agent
fi

# Restart PipeWire services to apply the changes
sudo -u $USER systemctl --user restart pipewire.service pipewire-pulse.service wireplumber.service

echo "Bluetooth setup for PipeWire complete."
echo "Your Raspberry Pi will:"
echo " • stay discoverable/pairable forever"
echo " • auto-accept any pairing without PIN"
echo " • auto-connect to known devices"
echo 
echo "The Bluetooth audio streams will be automatically routed through PipeWire"
echo "with the optimal settings for your HiFiBerry DAC+ (${BITS}-bit at ${HZ}Hz)."
