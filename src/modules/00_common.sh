#!/bin/bash
# Common configuration and functions for all DietPi audio system scripts
# This file should be sourced by all other scripts

# Set strict error handling
set -e

# Common paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
CONFIG_DIR="$PROJECT_ROOT/config"
GETS_DIR="$PROJECT_ROOT/src/gets"
CONFIGS_DIR="$PROJECT_ROOT/src/configurations"
SNAPCLIENT_CONFIG_DIR="/etc/snapclient"

# Determine the real user (the one who ran sudo)
if [ -n "$SUDO_USER" ]; then
    REAL_USER="$SUDO_USER"
else
    REAL_USER="$(whoami)"
fi

# Define package groups as constants for better organization
BASIC_UTILS="git curl wget nano zsh ranger mpg123 gettext"
BUILD_TOOLS="build-essential autoconf automake libtool"
AUDIO_LIBS="alsa-utils sox libsox-fmt-all"
SHAIRPORT_DEPS="libpopt-dev libconfig-dev libavahi-client-dev libssl-dev libsoxr-dev libplist-dev libsodium-dev libavutil-dev libavcodec-dev libavformat-dev uuid-dev libgcrypt-dev xxd"
MDNS_DEPS="avahi-daemon libavahi-compat-libdnssd-dev libavahi-compat-libdnssd1 pkg-config"
EQ_PLUGINS="ladspa-sdk swh-plugins caps"
PIPEWIRE="pipewire-audio pipewire-bin wireplumber pipewire-alsa pipewire-pulse libspa-0.2-bluetooth pipewire-utils"
BLUETOOTH_PACKAGES="bluez"
LIBRESPOT_DEPS="build-essential pkg-config libpulse-dev libavahi-client-dev rustc cargo"
SHAIRPORT_PACKAGES="shairport-sync"

# Combine all package groups into a single list for one-time installation
ALL_PACKAGES="$BASIC_UTILS $BUILD_TOOLS $AUDIO_LIBS $SHAIRPORT_DEPS $MDNS_DEPS $EQ_PLUGINS $PIPEWIRE $BLUETOOTH_PACKAGES $LIBRESPOT_DEPS $SHAIRPORT_PACKAGES"

# Set environment
DEVICE_NAME="Cloudspeaker"
BITRATE=320
VOLUME=100
HZ=48000
CHANNELS=2
BITS=32
VOLUME_RANGE=60


# Common functions
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

install_packages() {
    log_message "Installing packages: $*"
    apt-get install -y -qq --no-install-recommends "$@" 2>&1 | grep -v "^Preparing\|^Unpacking\|^Selecting\|^Setting up\|^Processing\|^Building\|^Configuring\|^Created symlink\|^Adding\|^Generating\|^Updating"
}

ensure_directory() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
    fi
}

backup_file() {
    if [ -f "$1" ]; then
        log_message "Backing up $1 to $1.bak"
        cp "$1" "$1.bak"
    fi
}

# usage: render /path/to/template > /dest/file
# EXAMPLE USAGE:
# variables the template expects
# export PORT=8080
# export SERVER_NAME=cloudspeaker.local
# export UPSTREAM=127.0.0.1:3000

# render into place
# render nginx.conf.tmpl > /etc/nginx/conf.d/cloudspeaker.conf
render() {
  local tpl=$1; shift
  # 1) read template
  # 2) replace {{VAR}} with $VAR from current env
  # 3) print to stdout
  sed -e 's/{{\([^}]\+\)}}/${\1}/g' "$tpl" | envsubst "$(
      # expose only the variables that actually appear in the template
      grep -o '{{[^}]\+}}' "$tpl" | tr -d '{}' | sort -u | sed 's/^/$/')" 
}

# Export variables so they're available to subshells
export CHANNELS HZ BITS DEVICE_NAME BITRATE VOLUME VOLUME_RANGE SCRIPT_DIR PROJECT_ROOT CONFIG_DIR GETS_DIR CONFIGS_DIR REAL_USER