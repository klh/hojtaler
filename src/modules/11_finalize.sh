#!/bin/bash
# Finalize setup for DietPi audio system
# This script performs final checks and configurations

# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

echo "Finalizing setup..."

# Create config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Create the status check script directly in the config directory
cat > "$CONFIG_DIR/check_status.sh" << 'EOL'
#!/bin/bash
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
EOL

# Make the status check script executable
chmod +x "$CONFIG_DIR/check_status.sh"

# Copy all configuration scripts to the config directory
for script in "$CONFIGS_DIR"/*/*.sh; do
  if [ -f "$script" ]; then
    script_name=$(basename "$script")
    cp "$script" "$CONFIG_DIR/$script_name"
    chmod +x "$CONFIG_DIR/$script_name"
  fi
done

# Set correct ownership for all config files
chown -R "$REAL_USER:$REAL_USER" "$CONFIG_DIR"
chmod -R 755 "$CONFIG_DIR"

# Cap the volume at 80% to prevent HiFiBerry crashes
echo "Setting maximum volume to 80% to prevent HiFiBerry crashes..."
if command -v amixer &> /dev/null; then
  amixer -c 0 sset Master 80% || true
fi

if command -v wpctl &> /dev/null; then
  # Set PipeWire volume to 80% (0.8)
  wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.8 || true
fi

# Run the status check
echo "Running status check..."
"$CONFIG_DIR/check_status.sh"

# Test audio output to verify everything is working
echo ""
echo "Testing audio output..."
echo "You should hear a confirmation sound..."

# Check if the setup_complete.mp3 file exists before trying to play it
if [ -f "$GETS_DIR/setup_complete.mp3" ]; then
  # Play the file with appropriate volume and format
  mpg123 -q -f 2600 --stereo -e s32 "$GETS_DIR/setup_complete.mp3" || {
    echo "Failed to play audio confirmation. Check your audio connections."
  }
else
  echo "Setup complete confirmation sound file not found. Skipping audio test."
  # Create a test tone as fallback
  if command -v sox &> /dev/null; then
    echo "Playing test tone instead..."
    sox -n -r 44100 -c 2 -b 32 /tmp/test_tone.wav synth 1 sine 440 fade 0 1 0.5
    aplay -D default /tmp/test_tone.wav
    rm -f /tmp/test_tone.wav
  fi
fi

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
