#!/bin/bash
# Build librespot from source for DietPi audio system
# This script builds either the latest release or the HEAD of librespot from GitHub

# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

log_message "Building librespot (Spotify Connect) from source..."


# Determine clone strategy: HEAD vs latest release
if [[ "${LIBRESPOT_HEAD:-false}" == "true" ]]; then
  log_message "LIBRESPOT_HEAD is true: cloning HEAD of librespot"
  git clone --depth 1 \
    https://github.com/librespot-org/librespot.git \
    "$GETS_DIR/librespot"
else
  log_message "Fetching latest release tag for librespot"
  LATEST_TAG=$(curl -s https://api.github.com/repos/librespot-org/librespot/releases/latest \
    | grep '"tag_name":' \
    | sed -E 's/.*"([^"]+)".*/\1/')
  log_message "Latest release tag: $LATEST_TAG"
  git clone --branch "$LATEST_TAG" --depth 1 \
    https://github.com/librespot-org/librespot.git \
    "$GETS_DIR/librespot"

    # Create a Cargo.toml override to fix the env_logger dependency issue
    mkdir -p .cargo
    cat > .cargo/config.toml << 'EOL'
    [patch.crates-io]
    env_logger = { version = "=0.10.0" }
    EOL
fi

cd "$GETS_DIR/librespot"

# Build librespot with ALSA backend and DNS-SD for discovery
log_message "Building librespot with ALSA backend..."
cargo build --release --features "alsa-backend with-dns-sd"

# Install the binary
cp target/release/librespot /usr/local/bin/
chmod +x /usr/local/bin/librespot

log_message "librespot has been built and installed successfully."
cd "$PROJECT_ROOT"