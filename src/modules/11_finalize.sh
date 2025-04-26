#!/bin/bash
# Finalize setup for DietPi audio system
# This script performs final checks and configurations

# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

echo "Finalizing setup..."

# Create a status check script

# Script to check the status of all audio services

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

echo "===== Audio System Status ====="
echo ""

echo "=== Hardware Configuration ==="
echo "ALSA devices:"
aplay -l
echo ""

echo "=== PipeWire Status ==="
echo "PipeWire:"
systemctl --user -M $USER@ status pipewire | grep Active
echo ""

echo "PipeWire PulseAudio:"
systemctl --user -M $USER@ status pipewire-pulse | grep Active
echo ""

echo "WirePlumber:"
systemctl --user -M $USER@ status wireplumber | grep Active
echo ""

echo "=== Audio Services Status ==="
echo "Bluetooth:"
systemctl status bluetooth | grep Active
echo ""

echo "Snapclient:"
systemctl status snapclient | grep Active
echo ""

echo "librespot (Spotify):"
systemctl status librespot | grep Active
echo ""

echo "Shairport-Sync (AirPlay):"
systemctl status shairport-sync | grep Active
echo ""

echo "=== Audio Test ==="
echo "To test audio output, run: paplay /usr/share/sounds/alsa/Front_Center.wav"
echo ""

echo "=== Network Info ==="
echo "IP Address:"
hostname -I
echo ""
echo "Hostname:"
hostname
echo ""

echo "===== End of Status Report ====="

# Create a test script to verify audio output
echo "Testing audio output..."
echo "You should hear a voice saying 'setup complete'"

mpg123 -f 2600 --stereo -e s32 $GETS_DIR/setup_complete.mp3

echo "Did you hear the audio? If not, check your connections and configuration."

# Final message
echo ""
echo "Setup finalized successfully!"
echo ""
echo "Your DietPi audio system is now configured with:"
echo "- ALSA with dmix and EQ"
echo "- Bluetooth A2DP audio"
echo "- Snapcast client"
echo "- Spotify Connect (librespot)"
echo "- AirPlay (Shairport-Sync)"
echo ""
echo "Useful scripts in $CONFIG_DIR:"
echo "- check_status.sh - Check the status of all services"
echo "- adjust_eq.sh - Adjust equalizer settings"
echo "- pair_bluetooth.sh - Pair Bluetooth devices"
echo "- snapclient_config.sh - Configure Snapcast client"
echo "- librespot_config.sh - Configure Spotify Connect"
echo "- shairport_config.sh - Configure AirPlay"
echo ""
echo "The system will reboot in 5 seconds to apply all changes..."
