#!/bin/bash
# Build librespot from source for DietPi audio system
# This script builds the latest version of librespot from GitHub

# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

log_message "Building librespot (Spotify Connect) from source..."

# Build dependencies are already installed by 02_install_deps.sh
log_message "Building librespot with dependencies already installed"

# Clone the latest librespot code (shallow clone)
LATEST_TAG=$(curl -s https://api.github.com/repos/librespot-org/librespot/releases/latest \
  | grep '"tag_name":' \
  | sed -E 's/.*"([^"]+)".*/\1/')
git clone --branch "$LATEST_TAG" --depth 1 \
  https://github.com/librespot-org/librespot.git "$GETS_DIR/librespot"

cd "$GETS_DIR/librespot"

# Create a Cargo.toml override to fix the env_logger dependency issue
mkdir -p .cargo
cat > .cargo/config.toml << 'EOL'
[patch.crates-io]
env_logger = { version = "=0.10.0" }
EOL

# Build librespot with ALSA backend and DNS-SD for discovery
log_message "Building librespot with ALSA backend..."

cargo build --release --features "alsa-backend with-dns-sd"

# Install the binary
cp target/release/librespot /usr/local/bin/
chmod +x /usr/local/bin/librespot

log_message "librespot has been built and installed successfully."
cd "$PROJECT_ROOT"