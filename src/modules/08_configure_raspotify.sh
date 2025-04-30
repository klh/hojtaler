#!/bin/bash
# Install Raspotify via prebuilt .deb for DietPi audio system
# This script downloads and installs the official arm64 .deb, then configures Raspotify

# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

log_message "Installing Raspotify (Spotify Connect) via prebuilt .deb..."

# Variables
DEB_URL="https://dtcooper.github.io/raspotify/raspotify-latest_arm64.deb"
DEB_FILE="$GETS_DIR/raspotify_latest_arm64.deb"
CONFIG_TPL="${PROJECT_ROOT}/src/configurations/raspotify.conf.tmpl"
CONFIG_FILE="/etc/raspotify/config.toml"

# Ensure GETS_DIR exists and is clean
mkdir -p "$GETS_DIR"
rm -f "$DEB_FILE"

# Download the prebuilt .deb
log_message "Downloading raspotify .deb from $DEB_URL"
curl -fsSL "$DEB_URL" -o "$DEB_FILE"

# Install the .deb and fix dependencies
log_message "Installing raspotify package"
dpkg -i "$DEB_FILE" || apt-get install -f -y

# Render configuration from template
log_message "Rendering raspotify configuration to $CONFIG_FILE"
mkdir -p "$(dirname "$CONFIG_FILE")"
render "$CONFIG_TPL" > "$CONFIG_FILE"

# Reload and restart raspotify service
log_message "Reloading systemd and restarting raspotify service"
systemctl daemon-reload
systemctl enable raspotify
systemctl restart raspotify

log_message "Raspotify installation and configuration complete."

