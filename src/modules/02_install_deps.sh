#!/bin/bash
# Install dependencies for DietPi audio system
# This script installs all required packages and software

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
CONFIG_DIR="$PROJECT_ROOT/config"

echo "Installing additional utilities..."
apt-get install -y --no-install-recommends git curl wget nano build-essential autoconf automake libtool libpopt-dev libconfig-dev libasound2-dev avahi-daemon libavahi-client-dev libssl-dev libsoxr-dev libplist-dev libsodium-dev libavutil-dev libavcodec-dev libavformat-dev uuid-dev libgcrypt-dev xxd libasound2-dev

systemctl enable avahi-daemon
systemctl start avahi-daemon

echo "Installing ALSA and audio utilities..."
apt-get install -y  libasound2-plugins ladspa-sdk swh-plugins alsa-utils alsa-tools

# Install LADSPA plugins for equalization
echo "Installing LADSPA plugins for equalization..."
apt-get install -y ladspa-sdk swh-plugins caps

echo "All dependencies installed successfully."
