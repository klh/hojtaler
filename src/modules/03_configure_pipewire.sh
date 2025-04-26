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

# --- 2. drop the EQ filter-sink definition in place -------------------
install -d -m 0755 /etc/pipewire/filter-chain.conf.d
install   -m 0644 /usr/share/pipewire/filter-chain/sink-eq6.conf \
                  /etc/pipewire/filter-chain.conf.d/30-eq.conf

# --- 3. Configure HiFiBerry DAC+ with optimal settings -------------
install -d -m 0755 /etc/pipewire

# Variables for the template are already defined in common.sh
# HZ, CHANNELS, BITS are used for the audio configuration

# Render the template and write to the configuration file
render "$CONFIGS_DIR/pipewire/20-hifiberry.conf.tmpl" > /etc/pipewire/20-hifiberry.conf

# --- 4. allow PipeWire to run for user even when nobody is logged in
loginctl enable-linger $USER

# --- 5. (re-)start the user services + pick the EQ sink as default ----
sudo -u $USER systemctl --user daemon-reload
sudo -u $USER systemctl --user enable --now \
        pipewire.service pipewire-pulse.service wireplumber.service

# give PipeWire a second to spawn the new sink, then make it default
sleep 1
sudo -u $USER wpctl set-default $(wpctl status | awk '/EQ Sink/ {print $2; exit}') || true

echo " PipeWire with 6-band EQ is ready. Reboot or re-log to apply system-wide."