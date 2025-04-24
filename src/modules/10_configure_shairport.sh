#!/bin/bash
# Configure Shairport-Sync for DietPi audio system
# This script sets up AirPlay functionality

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
CONFIG_DIR="$PROJECT_ROOT/config"

echo "Configuring Shairport-Sync (AirPlay)..."

# Install Shairport-Sync if not already installed
apt-get install -y shairport-sync

# Backup original configuration
if [ -f /etc/shairport-sync.conf ]; then
    cp /etc/shairport-sync.conf /etc/shairport-sync.conf.bak
fi

# Create Shairport-Sync configuration
cat > /etc/shairport-sync.conf << 'EOL'
// Shairport Sync Configuration

general = {
    name = "DietPi-AirPlay";
    interpolation = "soxr";
    output_backend = "alsa";
    mdns_backend = "avahi";
    drift_tolerance_in_seconds = 0.002;
    ignore_volume_control = "no";
    volume_range_db = 60;
    regtype = "_raop._tcp";
    playback_mode = "stereo";
};

alsa = {
    output_device = "default";
    mixer_control_name = "Master";
    mixer_device = "default";
    output_format = "S16";
    output_rate = 44100;
};

sessioncontrol = {
    run_this_before_play_begins = "/usr/bin/logger -t shairport-sync 'Starting playback'";
    run_this_after_play_ends = "/usr/bin/logger -t shairport-sync 'Ending playback'";
    wait_for_completion = "no";
    allow_session_interruption = "yes";
    session_timeout = 120;
};

diagnostics = {
    log_verbosity = 0;
};
EOL

# Create a configuration script for customizing Shairport-Sync settings
cat > "$CONFIG_DIR/shairport_config.sh" << 'EOL'
#!/bin/bash
# Script to configure Shairport-Sync settings

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Default values
NAME="DietPi-AirPlay"
VOLUME_RANGE=60

# Parse command line options
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --name)
        NAME="$2"
        shift
        shift
        ;;
        --volume-range)
        VOLUME_RANGE="$2"
        shift
        shift
        ;;
        *)
        echo "Unknown option: $1"
        echo "Usage: $0 [--name NAME] [--volume-range RANGE_DB]"
        exit 1
        ;;
    esac
done

# Update Shairport-Sync configuration
sed -i "s/name = \".*\";/name = \"$NAME\";/g" /etc/shairport-sync.conf
sed -i "s/volume_range_db = [0-9]*;/volume_range_db = $VOLUME_RANGE;/g" /etc/shairport-sync.conf

# Restart Shairport-Sync
systemctl restart shairport-sync

echo "Shairport-Sync configured with:"
echo "  Name: $NAME"
echo "  Volume range: $VOLUME_RANGE dB"
EOL

# Make the configuration script executable
chmod +x "$CONFIG_DIR/shairport_config.sh"

# Enable and start Shairport-Sync service
systemctl daemon-reload
systemctl enable shairport-sync
systemctl restart shairport-sync

echo "Shairport-Sync configuration complete."
echo "To customize Shairport-Sync settings, run: $CONFIG_DIR/shairport_config.sh [options]"
echo "Example: $CONFIG_DIR/shairport_config.sh --name \"Living Room\" --volume-range 70"
