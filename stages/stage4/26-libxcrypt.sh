#!/bin/bash
set -euo pipefail
# libxcrypt.html — Libxcrypt-4.5.2 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="libxcrypt-4.5.2.tar.xz"

lfs_init_package

sed -i '/strchr/s/const//' lib/crypt-{sm3,gost}-yescrypt.c
./configure --prefix=/usr --enable-hashes=strong,glibc --enable-obsolete-api=no --disable-static --disable-failure-tokens
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" install
make -j"${MAKE_JOBS}" distclean
./configure --prefix=/usr --enable-hashes=strong,glibc --enable-obsolete-api=glibc --disable-static --disable-failure-tokens
make -j"${MAKE_JOBS}"
cp -av --remove-destination .libs/libcrypt.so.1* /usr/lib

lfs_finish_package
