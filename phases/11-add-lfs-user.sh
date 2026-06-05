#!/bin/bash
set -euo pipefail
# Phase: add lfs user (chapter 04)

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/lfs-common.sh"

lfs_script_guard

if ! getent group lfs >/dev/null 2>&1; then
  groupadd lfs
fi

if ! getent passwd lfs >/dev/null 2>&1; then
  useradd -s /bin/bash -g lfs -m -k /dev/null lfs
fi

chown -v lfs "${LFS}"/{usr{,/*},var,etc,tools,sources}
case $(uname -m) in
  x86_64) chown -v lfs "${LFS}/lib64" ;;
esac
