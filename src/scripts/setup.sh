#!/bin/bash
# Main setup script for DietPi audio system with HiFiBerry AMP4
# This script orchestrates the entire setup process

set -e

# Configuration options - set to false to disable specific components
# By default, all components are enabled
ENABLE_BLUETOOTH=false
ENABLE_SNAPCLIENT=true
ENABLE_LIBRESPOT=true
ENABLE_SHAIRPORT=true

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
echo "====================================================="
echo "  DietPi Audio System Setup for Raspberry Pi Zero 2W"
echo "  with HiFiBerry AMP4"
echo "====================================================="

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Core system setup
echo "Preparing system..."
bash "$MODULES_DIR/01_system_prep.sh"

echo "Installing dependencies..."
bash "$MODULES_DIR/02_install_deps.sh"

echo "Configuring ALSA with dmix and EQ..."
bash "$MODULES_DIR/03_configure_alsa.sh"

# Optional components based on configuration
## echo "Setting up Bluetooth audio with auto-accept..."
## bash "$MODULES_DIR/04_setup_bluetooth_auto.sh"
## bash "$MODULES_DIR/04_setup_bluetooth.sh"

echo "Installing and configuring Snapclient..."
bash "$MODULES_DIR/05_install_snapclient.sh"
bash "$MODULES_DIR/06_configure_snapclient.sh"

echo "Setting up Librespot (Spotify Connect)..."
bash "$MODULES_DIR/07_build_librespot.sh"
bash "$MODULES_DIR/08_configure_librespot.sh"

echo "Setting up Shairport-sync (AirPlay)..."
bash "$MODULES_DIR/09_build_shairport.sh"
bash "$MODULES_DIR/10_configure_shairport.sh"

# Finalize setup
echo "Finalizing setup..."
bash "$MODULES_DIR/11_finalize.sh"

# Ensure the config directory is owned by the real user
if [ -d "$CONFIG_DIR" ]; then
    echo "Setting correct ownership for configuration directory..."
    chown -R "$REAL_USER:$REAL_USER" "$CONFIG_DIR"
    chmod -R 755 "$CONFIG_DIR"
fi

echo "===================================================="
echo "  Setup complete! Your audio system is ready."
echo "  Reboot your system to apply all changes."
echo "===================================================="

echo "Would you like to reboot now? (y/n)"
read -r answer
if [[ $answer =~ ^[Yy]$ ]]; then
    reboot
fi
