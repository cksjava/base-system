#!/bin/bash
set -euo pipefail
# linux-headers.html — Linux-6.18.10 API Headers (LFS ch.05, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="linux-6.18.10.tar.xz"

lfs_init_package

make -j"${MAKE_JOBS}" mrproper
make -j"${MAKE_JOBS}" headers
find usr/include -type f ! -name '*.h' -delete
cp -rv usr/include $LFS/usr

lfs_finish_package
