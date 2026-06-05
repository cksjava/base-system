#!/bin/bash
set -euo pipefail
# openssl.html — OpenSSL-3.6.1 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="openssl-3.6.1.tar.gz"

lfs_init_package

./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib shared zlib-dynamic
make -j"${MAKE_JOBS}"
sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make -j"${MAKE_JOBS}" MANSUFFIX=ssl install
mv -v /usr/share/doc/openssl /usr/share/doc/openssl-3.6.1
cp -vfr doc/* /usr/share/doc/openssl-3.6.1

lfs_finish_package
