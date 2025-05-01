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

# Manually copy the nqptp service file if it wasn't installed properly
if [ ! -f /lib/systemd/system/nqptp.service ] && [ -f ./nqptp.service ]; then
    log_message "Installing nqptp.service file manually..."
    cp ./nqptp.service /lib/systemd/system/
    chmod 644 /lib/systemd/system/nqptp.service
fi

# Reload systemd to recognize the new service
systemctl daemon-reload

# Enable and start nqptp service
systemctl enable nqptp || log_message "Warning: Failed to enable nqptp service"
systemctl start nqptp || log_message "Warning: Failed to start nqptp service"

log_message "Building shairport-sync with AirPlay 2 and metadata support..."
cd "$GETS_DIR"

# Clone shairport-sync repository (shallow clone)
if [ ! -d "shairport-sync" ]; then
    git clone --depth 1 https://github.com/mikebrady/shairport-sync.git
fi

# Build and install shairport-sync with AirPlay 2 support and PipeWire compatibility
cd shairport-sync
autoreconf -fi
./configure --sysconfdir=/etc --with-alsa --with-systemd\
    --with-avahi --with-pw --with-ssl=openssl \
    --with-airplay-2
make
make install


# Enable and start shairport-sync service
systemctl daemon-reload
systemctl enable shairport-sync
systemctl restart shairport-sync

log_message "Shairport-Sync with AirPlay 2 support has been built and installed successfully."
