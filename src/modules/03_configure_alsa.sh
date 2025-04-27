#!/bin/bash
# Configure ALSA with dmix and EQ for DietPi audio system
# This script sets up ALSA with device mixing and equalization

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
CONFIG_DIR="$PROJECT_ROOT/config"

# Create necessary directories
mkdir -p /etc/alsa/conf.d
mkdir -p "$CONFIG_DIR"

# Backup existing asound.conf if it exists
if [ -f /etc/asound.conf ]; then
    echo "Backing up existing asound.conf..."
    cp /etc/asound.conf /etc/asound.conf.bak
fi

# Create asound.conf with dmix and EQ configuration
echo "Creating ALSA configuration with dmix and EQ..."
cp "$PROJECT_ROOT/src/configurations/alsa/asound.conf" /etc/asound.conf

# Copy the EQ preset file to the config directory
cp "$PROJECT_ROOT/src/configurations/alsa/eq_presets.conf" "$CONFIG_DIR/eq_presets.conf"

# Copy the EQ adjustment script to the config directory
cp "$PROJECT_ROOT/src/configurations/alsa/adjust_eq.sh" "$CONFIG_DIR/adjust_eq.sh"

# Make the EQ adjustment script executable
chmod +x "$CONFIG_DIR/adjust_eq.sh"

# Test ALSA configuration
echo "Testing ALSA configuration..."
aplay -l

# Apply a default EQ preset (custom)
"$CONFIG_DIR/adjust_eq.sh" custom

echo "ALSA configuration with dmix and EQ completed."
echo "You can adjust EQ settings using: $CONFIG_DIR/adjust_eq.sh <preset>"
echo "Available presets: flat, bass, treble, mid, vshape, custom"
