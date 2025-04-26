
#!/bin/bash

# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

# Install Snapclient from specific .deb package
echo "Installing Snapclient from .deb package..."

# Download the .deb file to src/gets directory

if [ ! -f snapclient_0.31.0-1_arm64_bookworm_with-pulse.deb ]; then
    wget https://github.com/badaix/snapcast/releases/download/v0.31.0/snapclient_0.31.0-1_arm64_bookworm_with-pulse.deb -O $GETS_DIR/snapclient_0.31.0-1_arm64_bookworm_with-pulse.deb
fi

# Install the package
dpkg -i "$GETS_DIR/snapclient_0.31.0-1_arm64_bookworm_with-pulse.deb" || {
    # If dpkg fails due to dependencies, fix them
    apt-get -f install -y
    # Try installing again
    dpkg -i "$GETS_DIR/snapclient_0.31.0-1_arm64_bookworm_with-pulse.deb"
}