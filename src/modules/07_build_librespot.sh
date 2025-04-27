#!/bin/bash
# Build librespot from source for DietPi audio system
# This script builds the latest version of librespot from GitHub

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
GETS_DIR="$PROJECT_ROOT/src/gets"
BUILD_DIR="$GETS_DIR/librespot"

echo "Building librespot (Spotify Connect) from source..."

# Install build dependencies
apt-get update
apt-get install -y build-essential pkg-config libpulse-dev librust-alsa-sys-dev libavahi-client-dev rustc cargo

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

# Build librespot with ALSA backend
cargo build --release --no-default-features --features alsa-backend

# Install the binary
cp target/release/librespot /usr/local/bin/
chmod +x /usr/local/bin/librespot

echo "librespot has been built and installed successfully."
