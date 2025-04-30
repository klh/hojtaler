#!/bin/bash
# Install and configure Raspotify for DietPi audio system

# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

log_message "Installing Raspotify (Spotify Connect) via package..."

# Update package list and install raspotify
log_message "Updating APT repositories and installing raspotify package"
apt-get update
apt-get install -y raspotify

# Render raspotify configuration from template
TEMPLATE="${PROJECT_ROOT}/src/configurations/raspotify.conf.tmpl"
CONFIG_FILE="/etc/raspotify/config.toml"
log_message "Rendering raspotify configuration from $TEMPLATE to $CONFIG_FILE"

# Ensure output directory exists
mkdir -p "$(dirname "$CONFIG_FILE")"

# Render the template (using common "render" function)
render "$TEMPLATE" > "$CONFIG_FILE"

# Reload and restart the raspotify service
log_message "Reloading systemd and restarting raspotify service"
systemctl daemon-reload
systemctl enable raspotify
systemctl restart raspotify

log_message "Raspotify installation and templated configuration complete."
