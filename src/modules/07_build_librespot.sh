#!/bin/bash
# Build librespot from source for DietPi audio system
# This script builds the latest version of librespot from GitHub

# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

echo "Building librespot (Spotify Connect) from source..."

# Build dependencies are already installed by 02_install_deps.sh
log_message "Building librespot with dependencies already installed"

# Clone the latest librespot code (shallow clone)
sudo -u "$TARGET_USER" git clone --depth 1 https://github.com/librespot-org/librespot.git "$GETS_DIR/librespot"
cd "$GETS_DIR/librespot"

# Create a Cargo.toml override to fix the env_logger dependency issue
mkdir -p .cargo
cat > .cargo/config.toml << 'EOL'
[patch.crates-io]
env_logger = { version = "=0.10.0" }
EOL

# Build librespot with PipeWire (via PulseAudio) backend and DNS-SD for discovery
echo "Building librespot with PulseAudio backend for PipeWire compatibility..."

sudo -u "$TARGET_USER" cargo build --release --features pulseaudio-backend,dns-sd

# Install the binary
cp target/release/librespot /usr/local/bin/
chmod +x /usr/local/bin/librespot

echo "librespot has been built and installed successfully."
cd "$PROJECT_ROOT"