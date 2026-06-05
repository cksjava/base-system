#!/bin/bash
set -euo pipefail
# libelf.html — Libelf from Elfutils-0.194 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="elfutils-0.194.tar.bz2"

lfs_init_package

./configure --prefix=/usr --disable-debuginfod --enable-libdebuginfod=dummy
make -j"${MAKE_JOBS}" -C lib
make -j"${MAKE_JOBS}" -C libelf
make -j"${MAKE_JOBS}" -C libelf install
install -vm644 config/libelf.pc /usr/lib/pkgconfig
rm /usr/lib/libelf.a

lfs_finish_package
