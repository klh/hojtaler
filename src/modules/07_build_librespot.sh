#!/bin/bash
# Build librespot from source for  audio system
# This script builds either the latest release or the HEAD of librespot from GitHub

# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

log_message "Building librespot (Spotify Connect) from source..."

# Clone librespot source
if [[ "${LIBRESPOT_HEAD:-false}" == "true" ]]; then
  log_message "LIBRESPOT_HEAD is true: cloning HEAD of librespot"
  git clone --depth 1 https://github.com/librespot-org/librespot.git "$GETS_DIR/librespot"
else
  log_message "Fetching latest release tag for librespot"
  LATEST_TAG=$(curl -s https://api.github.com/repos/librespot-org/librespot/releases/latest \
    | grep '"tag_name":' \
    | sed -E 's/.*"([^"]+)".*/\1/')
  log_message "Latest release tag: $LATEST_TAG"
  git clone --branch "$LATEST_TAG" --depth 1 https://github.com/librespot-org/librespot.git "$GETS_DIR/librespot"

  # Fix env_logger compatibility
  mkdir -p "$GETS_DIR/librespot/.cargo"
  cat > "$GETS_DIR/librespot/.cargo/config.toml" << 'EOL'
[patch.crates-io]
env_logger = { version = "=0.10.0" }
EOL
fi


cd "$GETS_DIR/librespot"

log_message "Building librespot with ALSA backend and DNS-SD support..."
cargo build --release --features "alsa-backend with-dns-sd" --no-default-features


if [[ ! -x target/release/librespot ]]; then
  log_message "Error: librespot binary not found after build"
  exit 1
else
cp target/release/librespot /usr/local/bin/
chmod +x /usr/local/bin/librespot
log_message "librespot has been built and installed successfully."


cd "$PROJECT_ROOT"