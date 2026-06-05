#!/bin/bash
set -euo pipefail
# make.html — Make-4.4.1 (LFS ch.06, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="make-4.4.1.tar.gz"

lfs_init_package

./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess)
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" DESTDIR=$LFS install

lfs_finish_package
