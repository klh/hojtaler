#!/bin/bash
# System preparation for DietPi audio system
# This script prepares the base DietPi system for our audio setup


# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

log_message "speeding up installation via apt"
cp "$CONFIGS_DIR/apt/99parallel" "/etc/apt/apt.conf.d/99parallel"

log_message "sudoer and dbus setup"
install -d -m 0755 /etc/sudoers.d
install -m 0644 "$CONFIGS_DIR/sudoers.d/50-preserve-xdg" /etc/sudoers.d/50-preserve-xdg

log_message "profile.d setup"
install -d -m 0755 /etc/profile.d
install -m 0644 "$CONFIGS_DIR/profile.d/xdg-runtime.sh" /etc/profile.d/xdg-runtime.sh

# Enable required modules
log_message "Enabling required kernel modules..."
if ! grep -q "snd-bcm2835" /etc/modules; then
    echo "snd-bcm2835" >> /etc/modules
fi

sudo usermod -aG systemd-journal,adm,audio "$TARGET_USER"

log_message "umasking"
systemctl unmask systemd-logind
systemctl restart systemd-logind
loginctl enable-linger "$TARGET_USER"


log_message "clearing gets"

rm -rf "$GETS_DIR/*.*"

log_message "System preparation complete."
