#!/bin/bash
set -euo pipefail
# Phase: LFS user environment (chapter 04)

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/lfs-common.sh"

lfs_script_guard

LFS_HOME="$(getent passwd lfs | cut -d: -f6)"
lfs_write_lfs_bashrc "${LFS_HOME}"

if [[ -e /etc/bash.bashrc ]]; then
  mv -v /etc/bash.bashrc /etc/bash.bashrc.NOUSE
fi

echo "LFS environment installed in ${LFS_HOME}"
