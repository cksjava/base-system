#!/bin/bash
set -euo pipefail
# grep.html — Grep-3.12 (LFS ch.06, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="grep-3.12.tar.xz"

lfs_init_package

./configure --prefix=/usr --host=$LFS_TGT --build=$(./build-aux/config.guess)
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" DESTDIR=$LFS install

lfs_finish_package
