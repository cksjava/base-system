#!/bin/bash
set -euo pipefail
# udev and module baseline (LFS ch.9 §9.3–9.4).
# Machine-specific persistent symlinks belong in 90-local.rules after first boot;
# this phase only installs sane defaults and a documented template.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/lfs-common.sh"

lfs_script_guard

install -d -m755 /etc/udev/rules.d /etc/modprobe.d

systemctl enable systemd-udevd 2>/dev/null || true
systemctl enable systemd-modules-load 2>/dev/null || true

# Obsolete or rarely-needed drivers that udev may auto-load via modalias.
cat >/etc/modprobe.d/aryalinux.conf <<'EOF'
# See LFS ch.9 §9.3.3.3 — blacklist unwanted auto-loaded modules.
blacklist forte
blacklist floppy
EOF

# Optional modules that should load after their base driver (LFS §9.3.3.2 pattern).
cat >/etc/modprobe.d/aryalinux-softdep.conf <<'EOF'
# Example soft dependency; extend when you add wrapper modules (e.g. snd-pcm-oss).
# softdep snd-pcm post: snd-pcm-oss
EOF

# Document how to add stable /dev symlinks once hardware is known (LFS ch.9 §9.4).
cat >/etc/udev/rules.d/90-local.rules.example <<'EOF'
# Copy to 90-local.rules and edit on the installed system.
#
# Duplicate device nodes (e.g. /dev/video0 vs /dev/video1) are assigned in
# arbitrary order. Create stable names with udev rules keyed on attributes
# that do not change across reboots (vendor/product ID, serial, path, …).
#
# Inspect a device:
#   udevadm info -a -p /sys/class/video4linux/video0
#
# Example (replace IDs with values from udevadm):
# KERNEL=="video*", ATTRS{idVendor}=="0d81", ATTRS{idProduct}=="1910", SYMLINK+="webcam"
# KERNEL=="video*", ATTRS{idVendor}=="109e", ATTRS{device}=="0x036f", SYMLINK+="tvtuner"
EOF

# Rules with a .example suffix are ignored by udev; remove the suffix after editing.
chmod 644 /etc/udev/rules.d/90-local.rules.example
