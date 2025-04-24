#!/bin/bash
# Main setup script for DietPi audio system with HiFiBerry AMP4
# This script orchestrates the entire setup process

set -e

# Configuration options - set to false to disable specific components
# By default, all components are enabled
ENABLE_SYSTEM_PREP=true
ENABLE_DEPENDENCIES=true
ENABLE_ALSA=true
ENABLE_BLUETOOTH=false
ENABLE_SNAPCLIENT=true
ENABLE_LIBRESPOT=true
ENABLE_SHAIRPORT=true
ENABLE_FINALIZE=true

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

# Count how many steps are enabled
STEP_COUNT=0
if [ "$ENABLE_SYSTEM_PREP" = true ]; then ((STEP_COUNT++)); fi
if [ "$ENABLE_DEPENDENCIES" = true ]; then ((STEP_COUNT++)); fi
if [ "$ENABLE_ALSA" = true ]; then ((STEP_COUNT++)); fi
if [ "$ENABLE_BLUETOOTH" = true ]; then ((STEP_COUNT++)); fi
if [ "$ENABLE_SNAPCLIENT" = true ]; then ((STEP_COUNT++)); fi
if [ "$ENABLE_SNAPCLIENT" = true ]; then ((STEP_COUNT++)); fi  # Count twice for install and configure
if [ "$ENABLE_LIBRESPOT" = true ]; then ((STEP_COUNT++)); fi
if [ "$ENABLE_LIBRESPOT" = true ]; then ((STEP_COUNT++)); fi  # Count twice for build and configure
if [ "$ENABLE_SHAIRPORT" = true ]; then ((STEP_COUNT++)); fi
if [ "$ENABLE_SHAIRPORT" = true ]; then ((STEP_COUNT++)); fi  # Count twice for build and configure
if [ "$ENABLE_FINALIZE" = true ]; then ((STEP_COUNT++)); fi

# Initialize step counter
CURRENT_STEP=0

# 1. System preparation
if [ "$ENABLE_SYSTEM_PREP" = true ]; then
    ((CURRENT_STEP++))
    echo "[$CURRENT_STEP/$STEP_COUNT] Preparing system..."
    bash "$MODULES_DIR/01_system_prep.sh"
fi

# 2. Install dependencies
if [ "$ENABLE_DEPENDENCIES" = true ]; then
    ((CURRENT_STEP++))
    echo "[$CURRENT_STEP/$STEP_COUNT] Installing dependencies..."
    bash "$MODULES_DIR/02_install_deps.sh"
fi

# 3. Configure ALSA with dmix and EQ
if [ "$ENABLE_ALSA" = true ]; then
    ((CURRENT_STEP++))
    echo "[$CURRENT_STEP/$STEP_COUNT] Configuring ALSA with dmix and EQ..."
    bash "$MODULES_DIR/03_configure_alsa.sh"
fi

# 4. Setup Bluetooth audio (auto-accept)
if [ "$ENABLE_BLUETOOTH" = true ]; then
    ((CURRENT_STEP++))
    echo "[$CURRENT_STEP/$STEP_COUNT] Setting up Bluetooth audio with auto-accept..."
    bash "$MODULES_DIR/04_setup_bluetooth_auto.sh"
fi

# 5. Install Snapclient
if [ "$ENABLE_SNAPCLIENT" = true ]; then
    ((CURRENT_STEP++))
    echo "[$CURRENT_STEP/$STEP_COUNT] Installing Snapclient..."
    bash "$MODULES_DIR/05_install_snapclient.sh"
    
    # 6. Configure Snapclient
    ((CURRENT_STEP++))
    echo "[$CURRENT_STEP/$STEP_COUNT] Configuring Snapclient..."
    bash "$MODULES_DIR/06_configure_snapclient.sh"
fi

# 7. Build librespot (Spotify Connect)
if [ "$ENABLE_LIBRESPOT" = true ]; then
    ((CURRENT_STEP++))
    echo "[$CURRENT_STEP/$STEP_COUNT] Building librespot from source..."
    bash "$MODULES_DIR/07_build_librespot.sh"
    
    # 8. Configure librespot (Spotify Connect)
    ((CURRENT_STEP++))
    echo "[$CURRENT_STEP/$STEP_COUNT] Configuring librespot..."
    bash "$MODULES_DIR/08_configure_librespot.sh"
fi

# 9. Build shairport-sync (AirPlay)
if [ "$ENABLE_SHAIRPORT" = true ]; then
    ((CURRENT_STEP++))
    echo "[$CURRENT_STEP/$STEP_COUNT] Building shairport-sync from source..."
    bash "$MODULES_DIR/09_build_shairport.sh"
    
    # 10. Configure shairport-sync (AirPlay)
    ((CURRENT_STEP++))
    echo "[$CURRENT_STEP/$STEP_COUNT] Configuring shairport-sync..."
    bash "$MODULES_DIR/10_configure_shairport.sh"
fi

# 11. Finalize setup
if [ "$ENABLE_FINALIZE" = true ]; then
    ((CURRENT_STEP++))
    echo "[$CURRENT_STEP/$STEP_COUNT] Finalizing setup..."
    bash "$MODULES_DIR/11_finalize.sh"
fi

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
