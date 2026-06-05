#!/bin/bash
set -euo pipefail
# BLFS postlfs/initramfs.html — mkinitramfs + init.in (static copy)

BUILDER="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATA="${BUILDER}/static/postlfs/initramfs"
# shellcheck disable=SC1091
source "${BUILDER}/lib/lfs-common.sh"
# shellcheck disable=SC1091
source "${BUILDER}/config/vars.sh"

: "${KERNEL_RELEASE:?}"

lfs_script_guard

install -d -m755 /usr/sbin /usr/share/mkinitramfs
install -m755 "${DATA}/mkinitramfs" /usr/sbin/mkinitramfs
install -m755 "${DATA}/init.in" /usr/share/mkinitramfs/init.in

if [[ "${USE_INITRAMFS}" != "1" ]]; then
  echo "USE_INITRAMFS=0 — scripts installed, image not built"
  exit 0
fi

cd /boot
mkinitramfs "${KERNEL_RELEASE}"
# mkinitramfs writes initrd.img-${KERNEL_RELEASE} in the current directory (/boot)

