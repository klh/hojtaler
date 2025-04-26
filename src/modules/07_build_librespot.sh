#!/bin/bash
# Build librespot from source for DietPi audio system
# This script builds the latest version of librespot from GitHub

# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

echo "Building librespot (Spotify Connect) from source..."

# Install build dependencies
apt-get update
apt-get install -y build-essential pkg-config libpulse-dev libavahi-client-dev rustc cargo

# Create gets and build directories
mkdir -p "$GETS_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Clone the latest librespot code (shallow clone)
git clone --depth 1 https://github.com/librespot-org/librespot.git .

# Create a Cargo.toml override to fix the env_logger dependency issue
mkdir -p .cargo
cat > .cargo/config.toml << 'EOL'
[patch.crates-io]
env_logger = { version = "=0.10.0" }
EOL

# Build librespot with PipeWire (via PulseAudio) backend and DNS-SD for discovery
echo "Building librespot with PulseAudio backend for PipeWire compatibility..."
cargo build --release --no-default-features --features pulseaudio-backend,dns-sd

# Install the binary
cp target/release/librespot /usr/local/bin/
chmod +x /usr/local/bin/librespot

echo "librespot has been built and installed successfully."
