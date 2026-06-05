#!/bin/bash
set -euo pipefail
# bzip2.html — Bzip2-1.0.8 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="bzip2-1.0.8.tar.gz"

lfs_init_package

patch -Np1 -i ../bzip2-1.0.8-install_docs-1.patch
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
make -j"${MAKE_JOBS}" -f Makefile-libbz2_so
make -j"${MAKE_JOBS}" clean
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" PREFIX=/usr install
cp -av libbz2.so.* /usr/lib
ln -sfv libbz2.so.1.0.8 /usr/lib/libbz2.so
ln -sfv libbz2.so.1.0.8 /usr/lib/libbz2.so.1
cp -v bzip2-shared /usr/bin/bzip2
for i in /usr/bin/{bzcat,bunzip2}; do
ln -sfv bzip2 $i
done
rm -fv /usr/lib/libbz2.a

lfs_finish_package
