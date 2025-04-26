#!/usr/bin/env bash
# ----------------------------------------------------------------------
# PipeWire + 6-band EQ setup for DietPi (headless)
#   • works on Bookworm-based DietPi images
#   • assumes the normal user exists
#   • runs only once, is fully non-interactive
# ----------------------------------------------------------------------

# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

# --- 1. PipeWire packages are already installed by 02_install_deps.sh ---
log_message "Configuring PipeWire..."

sudo -iu "$TARGET_USER" systemctl --user daemon-reload
sudo -iu "$TARGET_USER" systemctl --user enable --now pipewire.service pipewire-pulse.service wireplumber.service

# --- 2. drop the EQ filter-sink definition in place -------------------
install -d -m 0755 /etc/pipewire/filter-chain.conf.d
install   -m 0644 "$CONFIGS_DIR/pipewire/filter-chain.conf.d/30-eq.conf" \
                  /etc/pipewire/filter-chain.conf.d/30-eq.conf

# --- 3. Configure HiFiBerry DAC+ with optimal settings -------------
install -d -m 0755 /etc/pipewire

# --- 4. Configure HiFiBerry DAC+ with optimal settings -------------
install -m 0644 "$CONFIGS_DIR/pipewire/90-default-eq-sink.lua" \
                  /usr/share/wireplumber/main.lua.d/90-default-eq-sink.lua

# Variables for the template are already defined in common.sh
# HZ, CHANNELS, BITS are used for the audio configuration

# Render the template and write to the configuration file
render "$CONFIGS_DIR/pipewire/20-hifiberry.conf.tmpl" > /etc/pipewire/20-hifiberry.conf

# give PipeWire a second to spawn the new sink, then make it default
sleep 1
sudo -iu "$TARGET_USER" systemctl --user restart wireplumber

echo " PipeWire with 6-band EQ is ready. Reboot or re-log to apply system-wide."