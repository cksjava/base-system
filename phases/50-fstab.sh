#!/bin/bash
set -euo pipefail
# /etc/fstab — UUID only (no /dev/sdX); values from config/build.conf

BUILDER="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "${BUILDER}/config/vars.sh"
# shellcheck disable=SC1091
source "${BUILDER}/lib/lfs-common.sh"

lfs_require_disk_config
lfs_script_guard

{
  echo "# Begin /etc/fstab (generated — UUID-based)"
  printf 'UUID=%s  /  %s  defaults,noatime  0  1\n' "${ROOT_UUID}" "${ROOT_FSTYPE}"
  if [[ -n "${SWAP_UUID:-}" ]]; then
    printf 'UUID=%s  swap  swap  pri=1  0  0\n' "${SWAP_UUID}"
  fi
  if [[ -n "${ESP_UUID:-}" ]]; then
    printf 'UUID=%s  %s  vfat  defaults,codepage=437,iocharset=iso8859-1  0  1\n' \
      "${ESP_UUID}" "${ESP_MOUNT}"
  fi
  echo "# End /etc/fstab"
} >/etc/fstab

