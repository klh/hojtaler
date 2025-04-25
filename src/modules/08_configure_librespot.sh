#!/bin/bash
# Configure librespot for DietPi audio system
# This script sets up Spotify Connect functionality

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
CONFIG_DIR="$PROJECT_ROOT/config"

# Determine the real user (the one who ran sudo)
if [ -n "$SUDO_USER" ]; then
    REAL_USER="$SUDO_USER"
else
    REAL_USER="$(whoami)"
fi

echo "Configuring librespot (Spotify Connect)..."

# Check if librespot service file exists in configurations
if [ -f "$PROJECT_ROOT/src/configurations/librespot/librespot.service" ]; then
    # Install the base librespot service file from configurations
    echo "Installing librespot service file from configurations to /etc/systemd/system/"
    cp "$PROJECT_ROOT/src/configurations/librespot/librespot.service" /etc/systemd/system/
else
    # Create the service file directly
    echo "librespot.service not found in configurations, creating it directly"
    cat > /etc/systemd/system/librespot.service << 'EOL'
[Unit]
Description=Spotify Connect via librespot
After=network.target sound.target
Wants=sound.target

[Service]
Type=simple
ExecStart=/usr/local/bin/librespot --name "Cloudspeaker" --backend alsa --device default
Restart=on-failure
RestartSec=4
User=root
Group=audio

[Install]
WantedBy=multi-user.target
EOL
    
    # Also save it to the configurations directory for future use
    mkdir -p "$PROJECT_ROOT/src/configurations/librespot"
    cp /etc/systemd/system/librespot.service "$PROJECT_ROOT/src/configurations/librespot/"
fi

# Verify the service file was copied successfully
if [ ! -f "/etc/systemd/system/librespot.service" ]; then
    echo "ERROR: Failed to copy librespot.service to /etc/systemd/system/"
    exit 1
fi

echo "librespot.service file installed successfully"

# Create librespot service configuration
mkdir -p /etc/systemd/system/librespot.service.d
cp "$PROJECT_ROOT/src/configurations/librespot/librespot.service.override.conf" /etc/systemd/system/librespot.service.d/override.conf

# Update the name to Cloudspeaker if it's still set to DietPi-Spotify
sed -i 's/DietPi-Spotify/Cloudspeaker/g' /etc/systemd/system/librespot.service.d/override.conf

# Create config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Copy the configuration script to the config directory
cp "$PROJECT_ROOT/src/configurations/librespot/librespot_config.sh" "$CONFIG_DIR/librespot_config.sh"

# Make the configuration script executable and set correct ownership
chmod +x "$CONFIG_DIR/librespot_config.sh"
chown "$REAL_USER:$REAL_USER" "$CONFIG_DIR/librespot_config.sh"

# Enable and start librespot service
echo "Reloading systemd daemon"
systemctl daemon-reload

echo "Enabling librespot service"
systemctl enable librespot || {
    echo "ERROR: Failed to enable librespot service"
    echo "Checking if service file exists:"
    ls -la /etc/systemd/system/librespot.service
    echo "Checking service status:"
    systemctl status librespot || true
    exit 1
}

echo "Starting librespot service"
systemctl restart librespot || {
    echo "ERROR: Failed to start librespot service"
    echo "Checking service logs:"
    journalctl -u librespot --no-pager -n 20 || true
    exit 1
}

echo "librespot configuration complete."
echo "To customize librespot settings, run: $CONFIG_DIR/librespot_config.sh [options]"
echo "Example: $CONFIG_DIR/librespot_config.sh --name \"Living Room\" --bitrate 320 --volume 80"
