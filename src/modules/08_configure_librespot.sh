#!/bin/bash
# Configure librespot for DietPi audio system
# This script sets up Spotify Connect functionality

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
CONFIG_DIR="$PROJECT_ROOT/config"

echo "Configuring librespot (Spotify Connect)..."

# Create librespot service configuration
mkdir -p /etc/systemd/system/librespot.service.d
cp "$PROJECT_ROOT/src/configurations/librespot/librespot.service.override.conf" /etc/systemd/system/librespot.service.d/override.conf

# Update the name to Cloudspeaker if it's still set to DietPi-Spotify
sed -i 's/DietPi-Spotify/Cloudspeaker/g' /etc/systemd/system/librespot.service.d/override.conf

# Copy the configuration script to the config directory
cp "$PROJECT_ROOT/src/configurations/librespot/librespot_config.sh" "$CONFIG_DIR/librespot_config.sh"

# Make the configuration script executable
chmod +x "$CONFIG_DIR/librespot_config.sh"

# Enable and start librespot service
systemctl daemon-reload
systemctl enable librespot
systemctl restart librespot

echo "librespot configuration complete."
echo "To customize librespot settings, run: $CONFIG_DIR/librespot_config.sh [options]"
echo "Example: $CONFIG_DIR/librespot_config.sh --name \"Living Room\" --bitrate 320 --volume 80"
