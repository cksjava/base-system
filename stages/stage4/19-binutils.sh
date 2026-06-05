#!/bin/bash
set -euo pipefail
# binutils.html — Binutils-2.46.0 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="binutils-2.46.0.tar.xz"

lfs_init_package

mkdir -v build
cd       build
../configure --prefix=/usr --sysconfdir=/etc --enable-ld=default --enable-plugins --enable-shared --disable-werror --enable-64-bit-bfd --enable-new-dtags --with-system-zlib --enable-default-hash-style=gnu
make -j"${MAKE_JOBS}" tooldir=/usr
make -j"${MAKE_JOBS}" tooldir=/usr install
rm -rfv /usr/lib/lib{bfd,ctf,ctf-nobfd,gprofng,opcodes,sframe}.a /usr/share/doc/gprofng/

lfs_finish_package
