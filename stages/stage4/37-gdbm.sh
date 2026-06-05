#!/bin/bash
set -euo pipefail
# gdbm.html — GDBM-1.26 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="gdbm-1.26.tar.gz"

lfs_init_package

./configure --prefix=/usr --disable-static --enable-libgdbm-compat
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" install

lfs_finish_package
