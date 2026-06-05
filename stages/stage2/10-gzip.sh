#!/bin/bash
set -euo pipefail
# gzip.html — Gzip-1.14 (LFS ch.06, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="gzip-1.14.tar.xz"

lfs_init_package

./configure --prefix=/usr --host=$LFS_TGT
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" DESTDIR=$LFS install

lfs_finish_package
