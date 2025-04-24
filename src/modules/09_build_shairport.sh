#!/bin/bash
# Build and install shairport-sync with AirPlay 2 support
# This script builds nqptp and shairport-sync from source

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
CONFIG_DIR="$PROJECT_ROOT/config"
GETS_DIR="$PROJECT_ROOT/src/gets"

# Create gets directory if it doesn't exist
mkdir -p "$GETS_DIR"

echo "Building nqptp (required for AirPlay 2)..."
cd "$GETS_DIR"

# Clone nqptp repository (shallow clone)
if [ ! -d "nqptp" ]; then
    git clone --depth 1 https://github.com/mikebrady/nqptp.git
fi

# Build and install nqptp
cd nqptp
autoreconf -fi
./configure
make
make install

# Enable and start nqptp service
systemctl enable nqptp
systemctl start nqptp

echo "Building shairport-sync with AirPlay 2 and metadata support..."
cd "$GETS_DIR"

# Clone shairport-sync repository (shallow clone)
if [ ! -d "shairport-sync" ]; then
    git clone --depth 1 https://github.com/mikebrady/shairport-sync.git
fi

# Build and install shairport-sync
cd shairport-sync
autoreconf -fi
./configure --sysconfdir=/etc --with-alsa \
    --with-soxr --with-avahi --with-ssl=openssl \
    --with-metadata --with-airplay-2 --with-stdout \
    --with-pipe --with-convolution
make
make install

# Create shairport-sync user and group if they don't exist
if ! getent group shairport-sync >/dev/null; then
    groupadd -r shairport-sync
fi
if ! getent passwd shairport-sync >/dev/null; then
    useradd -r -M -g shairport-sync -s /usr/bin/nologin -G audio shairport-sync
fi

# Copy shairport-sync configuration
cp "$PROJECT_ROOT/src/configurations/shairport/shairport-sync.conf" /etc/shairport-sync.conf

# Create service override directory and copy the override file
mkdir -p /etc/systemd/system/shairport-sync.service.d
cp "$PROJECT_ROOT/src/configurations/shairport/shairport-sync.service.override.conf" /etc/systemd/system/shairport-sync.service.d/override.conf

# Enable and start shairport-sync service
systemctl daemon-reload
systemctl enable shairport-sync
systemctl restart shairport-sync

echo "Shairport-Sync with AirPlay 2 support has been built and installed successfully."
