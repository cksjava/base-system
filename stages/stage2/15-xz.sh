#!/bin/bash
set -euo pipefail
# xz.html — Xz-5.8.2 (LFS ch.06, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="xz-5.8.2.tar.xz"

lfs_init_package

./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess) --disable-static --docdir=/usr/share/doc/xz-5.8.2
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" DESTDIR=$LFS install
rm -v $LFS/usr/lib/liblzma.la

lfs_finish_package
