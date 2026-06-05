#!/bin/bash
set -euo pipefail
# zlib.html — Zlib-1.3.2 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="zlib-1.3.2.tar.gz"

lfs_init_package

./configure --prefix=/usr
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" install
rm -fv /usr/lib/libz.a

lfs_finish_package
