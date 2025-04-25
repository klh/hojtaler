#!/bin/bash
# Finalize setup for DietPi audio system
# This script performs final checks and configurations

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
CONFIG_DIR="$PROJECT_ROOT/config"

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

echo "=== ALSA Configuration ==="
echo "ALSA devices:"
aplay -l
echo ""

echo "=== Service Status ==="
echo "Bluetooth:"
systemctl status bluetooth | grep Active
echo ""

echo "BlueALSA:"
systemctl status bluealsa | grep Active
echo ""

echo "BlueALSA aplay:"
systemctl status bluealsa-aplay | grep Active
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
echo "To test audio output, run: aplay -D default /usr/share/sounds/alsa/Front_Center.wav"
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
echo "You should hear a voice saying 'Front Center'"

# Make sure the test sound exists
if [ ! -f /usr/share/sounds/alsa/Front_Center.wav ]; then
    echo "Test sound file not found. Installing alsa-utils package..."
    apt-get install -y alsa-utils
fi

# Play test sound
aplay -D default /usr/share/sounds/alsa/Front_Center.wav

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
