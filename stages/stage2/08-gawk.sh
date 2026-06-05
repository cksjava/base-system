#!/bin/bash
set -euo pipefail
# gawk.html — Gawk-5.3.2 (LFS ch.06, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="gawk-5.3.2.tar.xz"

lfs_init_package

sed -i 's/extras//' Makefile.in
./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess)
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" DESTDIR=$LFS install

lfs_finish_package
