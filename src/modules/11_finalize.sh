#!/bin/bash
# Finalize setup for DietPi audio system
# This script performs final checks and configurations

# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

log_message "Finalizing setup..."


log_message "===== Audio System Status ====="
log_message ""

log_message "=== Hardware Configuration ==="
log_message "ALSA devices:"
aplay -l
log_message ""

log_message "=== Audio Services Status ==="
log_message "Bluetooth:"
systemctl status bluetooth | grep Active
log_message ""

log_message "Snapclient:"
systemctl status snapclient | grep Active
log_message ""

log_message "librespot (Spotify):"
systemctl status librespot | grep Active
log_message ""

log_message "Shairport-Sync (AirPlay):"
systemctl status shairport-sync | grep Active
log_message ""

log_message "=== Audio Test ==="
log_message "To test audio output, run: aplay /usr/share/sounds/alsa/Front_Center.wav"
log_message ""

log_message "=== Network Info ==="
log_message "IP Address:"
hostname -I
log_message ""
log_message "Hostname:"
hostname
log_message ""

log_message "===== End of Status Report ====="


# Cap the volume at 80% to prevent HiFiBerry crashes
log_message "Setting maximum volume to 80% to prevent HiFiBerry crashes..."
amixer -c 0 sset Digital 80% unmute


# Play test sound
aplay -D default /usr/share/sounds/alsa/Front_Center.wav

log_message "Did you hear the audio? If not, check your connections and configuration."

  # Play the file with appropriate volume and format
  mpg123 -q -f 2600 --stereo -e s32 "$GETS_DIR/setup_complete.mp3" || {
    log_message "Failed to play audio confirmation. Check your audio connections."
  }

# Final message
log_message ""
log_message "Setup finalized successfully!"
log_message ""
log_message "Your DietPi audio system is now configured with:"
log_message "- ALSA with dmix and EQ"
log_message "- Bluetooth A2DP audio"
log_message "- Snapcast client"
log_message "- Spotify Connect (librespot)"
log_message "- AirPlay (Shairport-Sync)"
log_message "The system will reboot in 5 seconds to apply all changes..."
