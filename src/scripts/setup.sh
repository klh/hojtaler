#!/bin/bash
# Main setup script for DietPi audio system with HiFiBerry AMP4
# Usage: setup.sh [--force-build]

set -e

# Define minimal paths needed to source common.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
MODULES_DIR="$PROJECT_ROOT/src/modules"

# Source common configuration
source "$MODULES_DIR/00_common.sh"

# Create build directory if it doesn't exist
mkdir -p "$BUILD_DIR"

# parse flags
FORCE_BUILD=false
if [[ "$1" == "--force-build" ]]; then
  FORCE_BUILD=true
  shift
fi

log_message "Starting setup script (force-build=$FORCE_BUILD)"

if $FORCE_BUILD; then
  log_message "Clearing previous build stamps"
  rm -f "$BUILD_DIR"/*.built
fi

# Log start of script execution
log_message "Starting setup script"

# Configuration options - set to false to disable specific components
# By default, all components are enabled

#BLUETOOTH AUDIO
ENABLE_BLUETOOTH=false
ENABLE_SNAPCLIENT=true

## SPOTIFY CONNECT
ENABLE_RASPOTIFY=false #use raspotify
DISABLE_RASPOTIFY=false #use raspotify only to get a librespot build
ENABLE_LIBRESPOT=true
LIBRESPOT_HEAD=true

#AIRPLAY 2
ENABLE_SHAIRPORT=true

# Print header
log_message "====================================================="
log_message "  DietPi Audio System Setup for Raspberry Pi Zero 2W"
log_message "  with HiFiBerry AMP4"
log_message "  BLUETOOTH=$ENABLE_BLUETOOTH"
log_message "  SNAPCLIENT=$ENABLE_SNAPCLIENT"

log_message "  RASPOTIFY=$ENABLE_RASPOTIFY, DISABLE raspotify and use its built in librespot=$DISABLE_RASPOTIFY"
log_message "  LIBRESPOT,=$ENABLE_LIBRESPOT, HEAD=$LIBRESPOT_HEAD"
log_message "  SHAIRPORT=$ENABLE_SHAIRPORT"
log_message "  force-build=$FORCE_BUILD"
log_message "====================================================="

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   log_message "ERROR: This script must be run as root" 
   exit 1
fi

log_message "Running as root, proceeding with setup"

# Core system setup
log_message "Preparing system..."
bash "$MODULES_DIR/01_system_prep.sh" 2>&1 | tee -a "$LOG_FILE" || { log_message "ERROR: System preparation failed"; exit 1; }

log_message "Installing dependencies..."
bash "$MODULES_DIR/02_install_deps.sh" 2>&1 | tee -a "$LOG_FILE" || { log_message "ERROR: Dependencies installation failed"; exit 1; }

log_message "Configuring ALSA with dmix ..."
bash "$MODULES_DIR/03_configure_alsa.sh" 2>&1 | tee -a "$LOG_FILE" || { log_message "ERROR: ALSA configuration failed"; exit 1; }

# Optional components based on configuration
## echo "Setting up Bluetooth audio with auto-accept..."
## bash "$MODULES_DIR/04_setup_bluetooth_auto.sh"
## bash "$MODULES_DIR/04_setup_bluetooth.sh"

if [ "$ENABLE_SNAPCLIENT" = true ]; then
    log_message "Installing and configuring Snapclient..."
    bash "$MODULES_DIR/05_install_snapclient.sh" 2>&1 | tee -a "$LOG_FILE" || { log_message "ERROR: Snapclient installation failed"; exit 1; }
    bash "$MODULES_DIR/06_configure_snapclient.sh" 2>&1 | tee -a "$LOG_FILE" || { log_message "ERROR: Snapclient configuration failed"; exit 1; }
else
    log_message "Skipping Snapclient setup (disabled in configuration)"
fi

if [ "$ENABLE_LIBRESPOT" = true ]; then

    log_message "building librespot..."
    bash "$MODULES_DIR/07_build_librespot.sh" 2>&1 | tee -a "$LOG_FILE"
    log_message "configuring librespot..."
    bash "$MODULES_DIR/08_configure_librespot.sh" 2>&1 | tee -a "$LOG_FILE"
else
    log_message "Skipping Raspotify setup"
fi
if [ "$ENABLE_RASPOTIFY" = true ]; then

    log_message "Configuring Raspotify..."
    bash "$MODULES_DIR/08_configure_raspotify.sh" 2>&1 | tee -a "$LOG_FILE"
else
    log_message "Skipping Raspotify setup"
fi

if [ "$ENABLE_RASPOTIFY" = true ]; then

    log_message "disabling Raspotify & enabling librespot..."

    bash "$MODULES_DIR/08_configure_librespot.sh" 2>&1 | tee -a "$LOG_FILE"
    sudo systemctil disable raspotify
    sudo systemctl enable librespot
    sudo systemctl restart librespot
else
    log_message "Skipping Raspotify setup"
fi


if [ "$ENABLE_SHAIRPORT" = true ]; then

        log_message "Building Shairport-sync..."
        bash "$MODULES_DIR/09_build_shairport.sh" 2>&1 | tee -a "$LOG_FILE"
        touch "$BUILD_DIR/shairport.built"

    log_message "Configuring Shairport-sync..."
    bash "$MODULES_DIR/10_configure_shairport.sh" 2>&1 | tee -a "$LOG_FILE"
else
    log_message "Skipping Shairport-sync setup"
fi

# Finalize setup
log_message "Finalizing setup..."
bash "$MODULES_DIR/11_finalize.sh" 2>&1 | tee -a "$LOG_FILE" || { log_message "ERROR: Finalization failed"; exit 1; }

# Ensure the config directory is owned by the real user
if [ -d "$CONFIG_DIR" ]; then
    log_message "Setting correct ownership for configuration directory..."
    chown -R "$REAL_USER:$REAL_USER" "$CONFIG_DIR" 2>&1 | tee -a "$LOG_FILE" || log_message "WARNING: Failed to set ownership for config directory"
    chmod -R 755 "$CONFIG_DIR" 2>&1 | tee -a "$LOG_FILE" || log_message "WARNING: Failed to set permissions for config directory"
fi

log_message "====================================================="
log_message "  Setup complete! Your audio system is ready."
log_message "  Reboot your system to apply all changes."
log_message "  Log file available at: $LOG_FILE"
log_message "====================================================="

log_message "Asking user about reboot"
echo "Would you like to reboot now? (y/n)"
read -r answer
if [[ $answer =~ ^[Yy]$ ]]; then
    log_message "User requested reboot, rebooting system now"
    reboot
else
    log_message "User skipped reboot"
fi
