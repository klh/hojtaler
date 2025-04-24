#!/bin/bash
# Main setup script for DietPi audio system with HiFiBerry AMP4
# This script orchestrates the entire setup process

set -e

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

# Check if running on DietPi
if [ ! -f /boot/dietpi/.version ]; then
    echo "This script is intended to run on DietPi OS"
    echo "Please install DietPi first: https://dietpi.com/"
    exit 1
fi

# 1. System preparation
echo "[1/11] Preparing system..."
bash "$MODULES_DIR/01_system_prep.sh"

# 2. Install dependencies
echo "[2/11] Installing dependencies..."
bash "$MODULES_DIR/02_install_deps.sh"

# 3. Configure ALSA with dmix and EQ
echo "[3/11] Configuring ALSA with dmix and EQ..."
bash "$MODULES_DIR/03_configure_alsa.sh"

# 4. Setup Bluetooth audio (auto-accept)
echo "[4/11] Setting up Bluetooth audio with auto-accept..."
bash "$MODULES_DIR/04_setup_bluetooth_auto.sh"

# 5. Install Snapclient
echo "[5/11] Installing Snapclient..."
bash "$MODULES_DIR/05_install_snapclient.sh"

# 6. Configure Snapclient
echo "[6/11] Configuring Snapclient..."
bash "$MODULES_DIR/06_configure_snapclient.sh"

# 7. Build librespot (Spotify Connect)
echo "[7/11] Building librespot from source..."
bash "$MODULES_DIR/07_build_librespot.sh"

# 8. Configure librespot (Spotify Connect)
echo "[8/11] Configuring librespot..."
bash "$MODULES_DIR/08_configure_librespot.sh"

# 9. Build shairport-sync (AirPlay)
echo "[9/11] Building shairport-sync from source..."
bash "$MODULES_DIR/09_build_shairport.sh"

# 10. Configure shairport-sync (AirPlay)
echo "[10/11] Configuring shairport-sync..."
bash "$MODULES_DIR/10_configure_shairport.sh"

# 11. Finalize setup
echo "[11/11] Finalizing setup..."
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
