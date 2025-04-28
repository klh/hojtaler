#!/bin/bash
# Build and install shairport-sync with AirPlay 2 support
# This script builds nqptp and shairport-sync from source

# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

# Create gets directory if it doesn't exist
mkdir -p "$GETS_DIR"

log_message "Building nqptp (required for AirPlay 2)..."
cd "$GETS_DIR"

# Clone nqptp repository (shallow clone)
if [ ! -d "nqptp" ]; then
    git clone --depth 1 https://github.com/mikebrady/nqptp.git
fi

# Build and install nqptp
cd nqptp
autoreconf -fi
./configure --with-systemd-startup
make
make install

# Enable and start nqptp service
systemctl enable nqptp
systemctl start nqptp

log_message "Building shairport-sync with AirPlay 2 and metadata support..."
cd "$GETS_DIR"

# Clone shairport-sync repository (shallow clone)
if [ ! -d "shairport-sync" ]; then
    git clone --depth 1 https://github.com/mikebrady/shairport-sync.git
fi

# Build and install shairport-sync with AirPlay 2 support and PipeWire compatibility
cd shairport-sync
autoreconf -fi
./configure --sysconfdir=/etc --with-alsa \
    --with-soxr --with-avahi --with-ssl=openssl \
    --with-metadata --with-airplay-2 --with-stdout --with-pipe
make
make install



# Copy shairport-sync configuration
cp "$PROJECT_ROOT/src/configurations/shairport/shairport-sync.conf" /etc/shairport-sync.conf

# Create service override directory and copy the override file
mkdir -p /etc/systemd/system/shairport-sync.service.d
cp "$PROJECT_ROOT/src/configurations/shairport/shairport-sync.service.override.conf" /etc/systemd/system/shairport-sync.service.d/override.conf

# Enable and start shairport-sync service
systemctl daemon-reload
systemctl enable shairport-sync
systemctl restart shairport-sync

log_message "Shairport-Sync with AirPlay 2 support has been built and installed successfully."
