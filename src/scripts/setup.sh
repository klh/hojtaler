#!/bin/bash
# Main setup script for DietPi audio system with HiFiBerry AMP4
# This script orchestrates the entire setup process

set -e

# Setup logging
LOG_FILE="$(dirname "$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")")/setup.log"

# Function to log messages to both console and log file
log_message() {
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $1"
    echo "[$timestamp] $1" >> "$LOG_FILE"
}

# Log start of script execution
log_message "Starting setup script"

# Configuration options - set to false to disable specific components
# By default, all components are enabled
ENABLE_BLUETOOTH=false
ENABLE_SNAPCLIENT=true
ENABLE_LIBRESPOT=true
ENABLE_SHAIRPORT=true

log_message "Configuration: BLUETOOTH=$ENABLE_BLUETOOTH, SNAPCLIENT=$ENABLE_SNAPCLIENT, LIBRESPOT=$ENABLE_LIBRESPOT, SHAIRPORT=$ENABLE_SHAIRPORT"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
CONFIG_DIR="$PROJECT_ROOT/config"
MODULES_DIR="$PROJECT_ROOT/src/modules"

# Determine the real user (the one who ran sudo)
if [ -n "$SUDO_USER" ]; then
    REAL_USER="$SUDO_USER"
else
    REAL_USER="$(whoami)"
fi

# Print header
log_message "====================================================="
log_message "  DietPi Audio System Setup for Raspberry Pi Zero 2W"
log_message "  with HiFiBerry AMP4"
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

log_message "Configuring PIPEWIRE with dmix and EQ..."
bash "$MODULES_DIR/03_configure_pipewire.sh" 2>&1 | tee -a "$LOG_FILE" || { log_message "ERROR: PIPEWIRE configuration failed"; exit 1; }

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
    log_message "Setting up Librespot (Spotify Connect)..."
    bash "$MODULES_DIR/07_build_librespot.sh" 2>&1 | tee -a "$LOG_FILE" || { log_message "ERROR: Librespot build failed"; exit 1; }
    bash "$MODULES_DIR/08_configure_librespot.sh" 2>&1 | tee -a "$LOG_FILE" || { log_message "ERROR: Librespot configuration failed"; exit 1; }
else
    log_message "Skipping Librespot setup (disabled in configuration)"
fi

if [ "$ENABLE_SHAIRPORT" = true ]; then
    log_message "Setting up Shairport-sync (AirPlay)..."
    bash "$MODULES_DIR/09_build_shairport.sh" 2>&1 | tee -a "$LOG_FILE" || { log_message "ERROR: Shairport-sync build failed"; exit 1; }
    bash "$MODULES_DIR/10_configure_shairport.sh" 2>&1 | tee -a "$LOG_FILE" || { log_message "ERROR: Shairport-sync configuration failed"; exit 1; }
else
    log_message "Skipping Shairport-sync setup (disabled in configuration)"
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
