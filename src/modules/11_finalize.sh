#!/bin/bash
# Finalize setup for DietPi audio system
# This script performs final checks and configurations

# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

echo "Finalizing setup..."

# Create a status check script
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

# Create a README file with instructions
cat > "$CONFIG_DIR/README.md" << 'EOL'
# DietPi Audio System

This is a complete audio system for Raspberry Pi Zero 2 W with HiFiBerry AMP4 HAT.

## Features
- Multiple audio sources with automatic switching:
  - Spotify Connect (librespot)
  - AirPlay (Shairport-Sync)
  - Bluetooth A2DP
  - Snapcast client
- Audio equalization (bass, treble, mids)
- ALSA dmix for hardware sharing

## Configuration Scripts

### Check System Status
```
sudo /path/to/config/check_status.sh
```

### Adjust Equalizer
```
sudo /path/to/config/adjust_eq.sh <preset>
```
Available presets: flat, bass, treble, mid, vshape

### Pair Bluetooth Device
```
sudo /path/to/config/pair_bluetooth.sh
```

### Configure Snapclient
```
sudo /path/to/config/snapclient_config.sh <snapserver_ip>
```

### Configure librespot (Spotify)
```
sudo /path/to/config/librespot_config.sh [options]
```
Example: `sudo /path/to/config/librespot_config.sh --name "Living Room" --bitrate 320 --volume 80`

### Configure Shairport-Sync (AirPlay)
```
sudo /path/to/config/shairport_config.sh [options]
```
Example: `sudo /path/to/config/shairport_config.sh --name "Living Room" --volume-range 70`

## Troubleshooting

If audio isn't working:
1. Check service status: `sudo /path/to/config/check_status.sh`
2. Test ALSA output: `aplay -D default /usr/share/sounds/alsa/Front_Center.wav`
3. Check logs: `journalctl -u librespot` or `journalctl -u shairport-sync`
EOL

# Create a test script to verify audio output
cat > "$CONFIG_DIR/test_audio.sh" << 'EOL'
#!/bin/bash
# Script to test audio output

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

echo "Testing audio output..."
echo "You should hear a voice saying 'Front Center'"

# Play test sound
aplay -D default /usr/share/sounds/alsa/Front_Center.wav

echo "Did you hear the audio? If not, check your connections and configuration."
EOL

# Make the test script executable
chmod +x "$CONFIG_DIR/test_audio.sh"

# Run the status check
echo "Running status check..."
"$CONFIG_DIR/check_status.sh"

# Test audio output to verify ALSA chain
echo ""
echo "Testing audio output to verify ALSA chain is working..."

# Install required packages if not already installed
echo "Ensuring required packages are installed..."
apt-get install -y alsa-utils sox libsox-fmt-all

# Create a test tone using SoX with the correct format for HiFiBerry AMP4
echo "Creating test tone with correct format (S32_LE, 44100Hz)..."
sox -n -r 44100 -c 2 -b 32 /tmp/test_tone.wav synth 3 sine 440 fade 0 3 0.5

echo "Playing test tone..."
aplay -D default /tmp/test_tone.wav

# Try the standard test sound as well, but convert it first
if [ -f /usr/share/sounds/alsa/Front_Center.wav ]; then
    echo "Converting and playing 'Front Center' voice sample..."
    sox /usr/share/sounds/alsa/Front_Center.wav -r 44100 -c 2 -b 32 /tmp/front_center_converted.wav
    aplay -D default /tmp/front_center_converted.wav
fi

# Clean up temporary files
rm -f /tmp/test_tone.wav /tmp/front_center_converted.wav

echo "Audio test complete. If you didn't hear anything, check your connections and configuration."

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
echo "- test_audio.sh - Test audio output"
echo "- adjust_eq.sh - Adjust equalizer settings"
echo "- pair_bluetooth.sh - Pair Bluetooth devices"
echo "- snapclient_config.sh - Configure Snapcast client"
echo "- librespot_config.sh - Configure Spotify Connect"
echo "- shairport_config.sh - Configure AirPlay"
echo ""
echo "The system will reboot in 5 seconds to apply all changes..."
