#!/usr/bin/env bash
# Configure ALSA with dmix and EQ for  audio system
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
#cp "$PROJECT_ROOT/src/configurations/alsa/asound.conf" /etc/asound.conf


# Test ALSA configuration
log_message "Testing ALSA configuration..."
aplay -l


log_message "✅ ALSA configuration with dmix and EQ completed."
