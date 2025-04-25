#!/bin/bash
# Install dependencies for DietPi audio system
# This script installs all required packages and software

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
CONFIG_DIR="$PROJECT_ROOT/config"

# Define package groups as constants for better organization
BASIC_UTILS="git curl wget nano"
BUILD_TOOLS="build-essential autoconf automake libtool"
AUDIO_LIBS="libasound2-dev libasound2-plugins ladspa-sdk swh-plugins alsa-utils alsa-tools"
SHAIRPORT_DEPS="libpopt-dev libconfig-dev libavahi-client-dev libssl-dev libsoxr-dev libplist-dev libsodium-dev libavutil-dev libavcodec-dev libavformat-dev uuid-dev libgcrypt-dev xxd"
MDNS_DEPS="avahi-daemon"
EQ_PLUGINS="ladspa-sdk swh-plugins caps"

# Combine all package groups into a single list
ALL_PACKAGES="$BASIC_UTILS $BUILD_TOOLS $AUDIO_LIBS $SHAIRPORT_DEPS $MDNS_DEPS $EQ_PLUGINS"

# Install all packages in a single apt-get command for speed
echo "Installing dependencies..."
apt-get update
apt-get install -y --no-install-recommends $ALL_PACKAGES

# Enable and start required services
echo "Enabling and starting Avahi daemon for mDNS..."
systemctl enable avahi-daemon
systemctl start avahi-daemon

echo "All dependencies installed successfully."
