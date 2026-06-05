#!/bin/bash
set -euo pipefail
# LFS ch.9 — console keymap and font (config/build.conf)

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/lfs-common.sh"

lfs_script_guard

: "${KEYMAP:?}"
: "${CONSOLE_FONT:?}"

cat >/etc/vconsole.conf <<EOF
KEYMAP=${KEYMAP}
FONT=${CONSOLE_FONT}
EOF

localectl set-keymap "${KEYMAP}"
localectl set-x11-keymap "${KEYMAP}" 2>/dev/null || true
