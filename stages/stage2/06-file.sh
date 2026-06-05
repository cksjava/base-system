#!/bin/bash
set -euo pipefail
# file.html — File-5.46 (LFS ch.06, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="file-5.46.tar.gz"

lfs_init_package

mkdir build
pushd build
../configure --disable-bzlib --disable-libseccomp --disable-xzlib --disable-zlib
make -j"${MAKE_JOBS}"
popd
./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)
make -j"${MAKE_JOBS}" FILE_COMPILE=$(pwd)/build/src/file
make -j"${MAKE_JOBS}" DESTDIR=$LFS install
rm -v $LFS/usr/lib/libmagic.la

lfs_finish_package
