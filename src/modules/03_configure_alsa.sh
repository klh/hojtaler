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
echo "Creating ALSA configuration with dmix ..."
cp "$PROJECT_ROOT/src/configurations/alsa/asound.conf" /etc/asound.conf

# Set proper permissions for audio devices
log_message "Setting proper audio device permissions..."
chmod -R a+rwX /dev/snd/

# Ensure dietpi user is in the audio group
log_message "Adding dietpi user to audio group..."
usermod -aG audio dietpi

# Create ALSA state directory with proper permissions
log_message "Setting up ALSA state directory..."
mkdir -p /var/lib/alsa
chmod -R 777 /var/lib/alsa

# Test ALSA configuration
log_message "Testing ALSA configuration..."
aplay -l

log_message "✅ ALSA configuration with dmix and EQ completed."
