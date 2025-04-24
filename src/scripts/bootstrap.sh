#!/bin/bash
# Bootstrap script for DietPi audio system with HiFiBerry AMP4
# This script clones the repository and starts the setup process
# Usage: curl -sSL https://raw.githubusercontent.com/klh/hojtaler/refs/heads/main/src/scripts/bootstrap.sh | bash

set -e

echo "====================================================="
echo "  DietPi Audio System Bootstrap for Raspberry Pi"
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

# Install git if not already installed
if ! command -v git &> /dev/null; then
    echo "Installing git..."
    apt-get update
    apt-get install -y git
fi

# Set target directory
TARGET_DIR="$HOME/cloudspeaker"

# Create target directory if it doesn't exist, or clean it if it does
if [ -d "$TARGET_DIR" ]; then
    echo "Target directory already exists. Cleaning..."
    # Only remove contents, not the directory itself
    rm -rf "$TARGET_DIR"/*
else
    echo "Creating target directory..."
    mkdir -p "$TARGET_DIR"
fi

# Clone the repository
echo "Cloning the repository..."
git clone --depth 1 https://github.com/klh/hojtaler.git "$TARGET_DIR"

# Make setup script executable
chmod +x "$TARGET_DIR/src/scripts/setup.sh"

# Run the setup script
echo "Starting setup process..."
cd "$TARGET_DIR"
bash "$TARGET_DIR/src/scripts/setup.sh"

echo "Bootstrap complete!"
