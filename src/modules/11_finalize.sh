#!/bin/bash
# Finalize setup for DietPi audio system
# This script performs final checks and configurations

# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

log_message "Finalizing setup..."

# Function to check service status with better error handling
check_service_status() {
    local service_name="$1"
    local display_name="$2"
    
    log_message "$display_name:"
    if systemctl --quiet is-enabled "$service_name" 2>/dev/null; then
        log_message "  Enabled: YES"
    else
        log_message "  Enabled: NO (Service is not enabled)"
    fi
    
    if systemctl --quiet is-active "$service_name" 2>/dev/null; then
        log_message "  Active: YES (Service is running)"
        systemctl status "$service_name" | grep -E 'Active:|Main PID:' | sed 's/^/  /'
    else
        local status=$(systemctl is-active "$service_name" 2>/dev/null || echo "not-found")
        log_message "  Active: NO (Status: $status)"
        if [ "$status" != "not-found" ]; then
            # Show the last few lines of the journal for debugging
            log_message "  Recent logs:"
            journalctl -u "$service_name" -n 3 --no-pager | sed 's/^/    /'
        fi
    fi
    log_message ""
}

log_message "===== Audio System Status ====="
log_message ""

log_message "=== Hardware Configuration ==="
log_message "ALSA devices:"
aplay -l || log_message "  No ALSA devices found or aplay failed"
log_message ""

# Check if amixer is available and show mixer controls
log_message "ALSA mixer settings:"
if command -v amixer >/dev/null 2>&1; then
    amixer -c 0 sget Digital || amixer -c 0 sget Master || log_message "  No Master or Digital control found"
else
    log_message "  amixer command not available"
fi
log_message ""

log_message "=== Audio Services Status ==="
check_service_status "bluetooth" "Bluetooth"
check_service_status "snapclient" "Snapclient"
check_service_status "librespot" "Librespot (Spotify)"
check_service_status "shairport-sync" "Shairport-Sync (AirPlay)"

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


# Ensure audio devices have proper permissions before testing
log_message "Ensuring proper audio device permissions..."
chmod -R a+rwX /dev/snd/

# Make sure the user is in the audio group
if ! groups dietpi | grep -q audio; then
    log_message "Adding dietpi user to audio group..."
    usermod -aG audio dietpi
    # Apply group changes without requiring logout
    log_message "Applying group changes..."
    su - dietpi -c "id" > /dev/null 2>&1 || true
fi

# Cap the volume at 80% to prevent HiFiBerry crashes
log_message "Setting maximum volume to 80% to prevent HiFiBerry crashes..."
amixer -c 0 sset Digital 80% unmute

# Play test sound as root first to ensure it works
log_message "Testing audio as root..."
aplay -D default /usr/share/sounds/alsa/Front_Center.wav

# Test as the dietpi user to verify permissions
log_message "Testing audio as dietpi user..."
su - dietpi -c "aplay -D default /usr/share/sounds/alsa/Front_Center.wav" || {
    log_message "Warning: Audio test as dietpi user failed. This may indicate permission issues."
    log_message "Attempting to fix permissions..."
    chmod 666 /dev/snd/*
    su - dietpi -c "aplay -D default /usr/share/sounds/alsa/Front_Center.wav" || true
}

log_message "Did you hear the audio? If not, check your connections and configuration."

  # Play the file with appropriate volume and format
  mpg123 -q -f 2600 --stereo -e s32 "$BINARIES_DIR/setup_complete.mp3" || {
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
