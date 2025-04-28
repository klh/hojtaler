#!/bin/bash
# Install dependencies for DietPi audio system
# This script installs all required packages and software


# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

# Install all packages in a single command for speed
PACKAGE_COUNT=$(echo $ALL_PACKAGES | wc -w)
log_message "Installing $PACKAGE_COUNT dependencies..."
install_packages $ALL_PACKAGES

# Combine all package groups into a single list
ALL_PACKAGES="$BASIC_UTILS $BUILD_TOOLS $AUDIO_LIBS $SHAIRPORT_DEPS $MDNS_DEPS $EQ_PLUGINS"

# Install all packages in a single apt-get command for speed
log_message( "Installing dependencies..."
apt-get update
apt-get install -y $ALL_PACKAGES

# Enable and start required services
log_message( "Enabling and starting Avahi daemon for mDNS..."
systemctl enable avahi-daemon
systemctl start avahi-daemon

log_message( "All dependencies installed successfully."
