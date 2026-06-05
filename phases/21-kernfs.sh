#!/bin/bash
set -euo pipefail
# Phase: virtual kernel filesystems (chapter 07)

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/lfs-common.sh"

lfs_script_guard

mkdir -pv "${LFS}"/{dev,proc,sys,run}

mount -v --bind /dev "${LFS}/dev"
mount -vt devpts devpts -o gid=5,mode=0620 "${LFS}/dev/pts"
mount -vt proc proc "${LFS}/proc"
mount -vt sysfs sysfs "${LFS}/sys"
mount -vt tmpfs tmpfs "${LFS}/run"

if [[ -h /dev/shm ]]; then
  install -v -d -m 1777 "${LFS}$(readlink -f /dev/shm)"
else
  mount -vt tmpfs -o nosuid,nodev tmpfs "${LFS}/dev/shm"
fi
