#!/bin/bash
# System preparation for  audio system
# This script prepares the base  system for our audio setup


# Source common configuration
source "$(dirname "${BASH_SOURCE[0]}")/00_common.sh"

log_message "speeding up installation via apt"
cp "$CONFIGS_DIR/apt/99parallel" "/etc/apt/apt.conf.d/99parallel"

log_message "sudoer and dbus setup"
#install -d -m 0755 /etc/sudoers.d
#install -m 0644 "$CONFIGS_DIR/sudoers.d/50-preserve-xdg" /etc/sudoers.d/50-preserve-xdg

log_message "moving governor to performance"
install -m 0644 "$CONFIGS_DIR/governor/performance-governor.service" /etc/systemd/system/performance-governor.service
sudo systemctl daemon-reexec
sudo systemctl enable --now performance-governor

log_message "Setting realtime audio limits"
#install -m 0644 "$CONFIGS_DIR/limits/audio.conf" /etc/security/limits.d/audio.conf

log_message "profile.d setup"
#install -d -m 0755 /etc/profile.d
#install -m 0644 "$CONFIGS_DIR/profile.d/xdg-runtime.sh" /etc/profile.d/xdg-runtime.sh

log_message "powermanagement setup"
install -m 0644 "$CONFIGS_DIR/powermanagement/disable_audio_powersave.conf" /etc/modprobe.d/disable_audio_powersave.conf

# Only run update-initramfs if present
if command -v update-initramfs >/dev/null; then
  sudo update-initramfs -u
fi

sudo usermod -aG systemd-journal,adm,audio "$USERNAME"

log_message "umasking"
systemctl unmask systemd-logind
systemctl restart systemd-logind
loginctl enable-linger "$USERNAME"

log_message "Applying ALSA-related sysctl tuning"
if ! grep -q "fs.inotify.max_user_watches" /etc/sysctl.conf; then
 #   echo "fs.inotify.max_user_watches = 524288" >> /etc/sysctl.conf
fi

if ! grep -q "vm.swappiness" /etc/sysctl.conf; then
  #  echo "vm.swappiness = 10" >> /etc/sysctl.conf
fi

sysctl -p

log_message "clearing gets"

rm -rf "$GETS_DIR/*"

log_message "✅ System preparation complete."
