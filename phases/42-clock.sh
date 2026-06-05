#!/bin/bash
set -euo pipefail
# LFS ch.9 — clock and timezone (config/build.conf)

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/lfs-common.sh"

lfs_script_guard

: "${TIMEZONE:?}"
: "${HWCLOCK_UTC:?}"

if [[ "${HWCLOCK_UTC}" == "1" ]]; then
  cat >/etc/adjtime <<'EOF'
0.0 0 0.0
0
UTC
EOF
  timedatectl set-local-rtc 0
else
  cat >/etc/adjtime <<'EOF'
0.0 0 0.0
0
LOCAL
EOF
  timedatectl set-local-rtc 1
fi

timedatectl set-timezone "${TIMEZONE}"
systemctl disable systemd-timesyncd 2>/dev/null || true
