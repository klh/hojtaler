
#!/bin/bash

# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

# Install Snapclient from specific .deb package
log_message "Installing Snapclient from .deb package..."

SNAPVERSION="snapclient_0.31.0-1_arm64_bookworm.deb"

# Download the .deb file to src/gets directory
wget https://github.com/badaix/snapcast/releases/download/v0.31.0/$SNAPVERSION -O $GETS_DIR/$SNAPVERSION

# Install the package
dpkg -i "$GETS_DIR/$SNAPVERSION" || {
    # If dpkg fails due to dependencies, fix them
    apt-get -f install -y
    # Try installing again
    dpkg -i "$GETS_DIR/$SNAPVERSION"
}