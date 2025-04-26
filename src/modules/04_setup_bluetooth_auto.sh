#!/bin/bash
# Setup Bluetooth audio with auto-accept for DietPi audio system
# This script configures Bluetooth to automatically accept connections

set -euo pipefail


# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

echo "1) Installing Bluetooth packages..."
apt-get update
apt-get install -y bluez

echo "2) Enabling and starting Bluetooth service..."
systemctl enable bluetooth.service
systemctl start bluetooth.service

echo "3) Ensuring PipeWire Bluetooth module is active..."
# PipeWire's Bluetooth module is part of libspa-0.2-bluetooth package
# and is loaded automatically by wireplumber

# Verify that the user services are running
sudo -u $USER systemctl --user is-active pipewire.service pipewire-pulse.service wireplumber.service || {
    echo "Starting PipeWire services for user $USER"
    sudo -u $USER systemctl --user daemon-reload
    sudo -u $USER systemctl --user enable --now pipewire.service pipewire-pulse.service wireplumber.service
}

echo "4) Making Bluetooth forever discoverable & pairable..."
mkdir -p /etc/bluetooth

# Render Bluetooth configuration from template
# Variables for the template are already defined in common.sh
# DEVICE_NAME is used for the Bluetooth device name

# Render the template and write to the configuration file
render "$CONFIGS_DIR/bluetooth/bluetooth-main.conf.tmpl" > /etc/bluetooth/main.conf

echo "5) Installing zero-pin pairing agent..."

# Copy bt-agent.service for zero-pin pairing
cp "$CONFIGS_DIR/bluetooth/bt-agent.service" /etc/systemd/system/

systemctl daemon-reload
systemctl enable bt-agent.service
systemctl start bt-agent.service

echo "6) Configuring PipeWire Bluetooth settings..."

# Ensure the PipeWire config directory exists
mkdir -p /etc/pipewire/pipewire.conf.d

# Create a configuration file to enable Bluetooth support
cat > /etc/pipewire/pipewire.conf.d/20-bluetooth.conf << 'EOL'
# Enable Bluetooth support in PipeWire
bluez5.properties = {
    bluez5.enable-sbc-xq = true
    bluez5.enable-msbc = true
    bluez5.enable-hw-volume = true
    bluez5.headset-roles = [ hsp_hs hsp_ag hfp_hf hfp_ag ]
    bluez5.autoswitch-profile = true
}
EOL

# Restart PipeWire services to apply the changes
sudo -u $USER systemctl --user restart pipewire.service pipewire-pulse.service wireplumber.service

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
