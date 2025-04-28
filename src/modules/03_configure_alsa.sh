#!/usr/bin/env bash
# Configure ALSA with dmix and EQ for DietPi audio system
# This script sets up ALSA with device mixing and equalization

# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

# Create necessary directories
mkdir -p /etc/alsa/conf.d

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
log_message "Testing ALSA configuration..."
aplay -l

# Apply a default EQ preset (custom)
"$CONFIG_DIR/adjust_eq.sh" custom

log_message "ALSA configuration with dmix and EQ completed."
