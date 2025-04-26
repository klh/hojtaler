
#!/bin/bash

# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

# Install Snapclient from specific .deb package
echo "Installing Snapclient from .deb package..."

# Create gets directory if it doesn't exist
mkdir -p "$PROJECT_ROOT/src/gets"

# Download the .deb file to src/gets directory
cd "$PROJECT_ROOT/src/gets"
if [ ! -f snapclient_0.31.0-1_armhf_bookworm_with-pulse.deb ]; then
    wget https://github.com/badaix/snapcast/releases/download/v0.31.0/snapclient_0.31.0-1_armhf_bookworm_with-pulse.deb
fi

# Install the package
dpkg -i snapclient_0.31.0-1_armhf_bookworm_with-pulse.deb || {
    # If dpkg fails due to dependencies, fix them
    apt-get -f install -y
    # Try installing again
    dpkg -i snapclient_0.31.0-1_armhf_bookworm_with-pulse.deb
}