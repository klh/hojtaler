#!/bin/bash
# Finalize setup for DietPi audio system
# This script performs final checks and configurations

# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

echo "Finalizing setup..."


echo "===== Audio System Status ====="
echo ""

echo "=== Hardware Configuration ==="
echo "ALSA devices:"
aplay -l
echo ""

echo "=== PipeWire Status ==="
echo "PipeWire:"
systemctl status pipewire | grep Active
echo ""

echo "PipeWire PulseAudio:"
systemctl status pipewire-pulse | grep Active
echo ""

echo "WirePlumber:"
systemctl status wireplumber | grep Active
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
EOL

# Cap the volume at 80% to prevent HiFiBerry crashes
echo "Setting maximum volume to 80% to prevent HiFiBerry crashes..."
amixer -c 0 sset Digital 80% unmute

# Set PipeWire volume to 80% (0.8)
wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.8 || true

# Test audio output to verify everything is working
echo ""
echo "Testing audio output..."
echo "You should hear a confirmation sound..."


  # Play the file with appropriate volume and format
  mpg123 -q -f 2600 --stereo -e s32 "$GETS_DIR/setup_complete.mp3" || {
    echo "Failed to play audio confirmation. Check your audio connections."
  }

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
echo "The system will reboot in 5 seconds to apply all changes..."
