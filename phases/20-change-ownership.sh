#!/bin/bash
set -euo pipefail
# Phase: change ownership before chroot (chapter 07)

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/lfs-common.sh"

lfs_script_guard

chown --from=lfs -R root:root "${LFS}"/{usr,var,etc,tools}
chown -R root:root "${LFS}"/{lib,boot,sbin,lib64,bin} 2>/dev/null || true

case $(uname -m) in
  i?86)
    chown -v root "${LFS}/lib" 2>/dev/null || true
    ;;
esac
