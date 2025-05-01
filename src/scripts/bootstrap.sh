#!/bin/bash
# Bootstrap script for audio system with HiFiBerry AMP4
# This script clones the repository and starts the setup process
# Usage: curl -sSL https://raw.githubusercontent.com/klh/hojtaler/refs/heads/main/src/scripts/bootstrap.sh | bash

set -e

echo "====================================================="
echo "  Audio System Bootstrap for Raspberry Pi"
echo "  with HiFiBerry AMP4"
echo "====================================================="

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Install git if not already installed
if ! command -v git &> /dev/null; then
    echo "Installing git..."
    apt-get update
    apt-get install -y git
fi

# Determine the real user's home directory, even when run with sudo
if [ -n "$SUDO_USER" ]; then
    REAL_USER="$SUDO_USER"
    REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"
else
    REAL_USER="$(whoami)"
    REAL_HOME="$HOME"
fi

# Set target directory
TARGET_DIR="$REAL_HOME/cloudspeaker"

# Create target directory if it doesn't exist
if [ ! -d "$TARGET_DIR" ]; then
    echo "Creating target directory..."
    mkdir -p "$TARGET_DIR"
fi

# Check if the directory is a git repository already
if [ -d "$TARGET_DIR/.git" ]; then
    echo "Git repository already exists. Pulling latest changes..."
    cd "$TARGET_DIR"
    git pull
else
    # Clone the repository
    echo "Cloning the repository..."
    git clone --depth 1 https://github.com/klh/hojtaler.git "$TARGET_DIR"
fi

# Ensure the entire directory has the correct ownership
if [ -n "$SUDO_USER" ]; then
    echo "Setting correct ownership for the repository..."
    chown -R "$REAL_USER:$REAL_USER" "$TARGET_DIR"
fi

# Make setup script executable
chmod +x "$TARGET_DIR/src/scripts/setup.sh"

# Run the setup script
echo "Starting setup process..."
cd "$TARGET_DIR"
bash "$TARGET_DIR/src/scripts/setup.sh"

echo "Bootstrap complete!"
