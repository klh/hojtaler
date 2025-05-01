#!/bin/bash
# Configure and install librespot service for  audio system
# This script always uses the locally-built binary from $GETS_DIR/librespot

# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

log_message "Configuring librespot service..."

# Paths
LIBRESPOT_SRC="$GETS_DIR/librespot"
LIBRESPOT_BIN="/usr/local/bin/librespot"
SYSTEMD_DIR="/etc/systemd/system"
SERVICE_TPL="${PROJECT_ROOT}/src/configurations/librespot/librespot.service.tmpl"
OVERRIDE_TPL="${PROJECT_ROOT}/src/configurations/librespot/librespot.service.override.conf.tmpl"

# Ensure the binary exists from our build step
# Check for librespot binary or raspotify usage
if [[ "$ENABLE_RASPOTIFY" == "true" && "$DISABLE_RASPOTIFY" == "true" ]]; then
  log_message "Info: Using system-installed librespot via raspotify (stealing instance)"
  # Skip binary check since we rely on raspotify's systemd setup
else
  if [[ ! -x "$LIBRESPOT_SRC/target/release/librespot" ]]; then
    log_message "Error: built librespot binary not found at $LIBRESPOT_SRC/target/release/librespot"
    exit 1
  fi
fi
# Install the locally-built binary
cp "$LIBRESPOT_SRC/target/release/librespot" "$LIBRESPOT_BIN"
chmod +x "$LIBRESPOT_BIN"
log_message "Installed librespot binary to $LIBRESPOT_BIN"

# Render and install the main service unit
render "$SERVICE_TPL" > "$SYSTEMD_DIR/librespot.service"
# Apply overrides if present
if [[ -f "$OVERRIDE_TPL" ]]; then
  render "$OVERRIDE_TPL" > "$SYSTEMD_DIR/librespot.service.d/override.conf"
fi

# Reload systemd and enable/start the service
systemctl daemon-reload
systemctl enable librespot
systemctl restart librespot

log_message "librespot service configured and started successfully."
