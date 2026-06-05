#!/bin/bash
set -euo pipefail
# gcc-pass2.html — GCC-15.2.0 - Pass 2 (LFS ch.06, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="gcc-15.2.0.tar.xz"

lfs_init_package

tar -xf ../mpfr-4.2.2.tar.xz
mv -v mpfr-4.2.2 mpfr
tar -xf ../gmp-6.3.0.tar.xz
mv -v gmp-6.3.0 gmp
tar -xf ../mpc-1.3.1.tar.gz
mv -v mpc-1.3.1 mpc
case $(uname -m) in
x86_64)
sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
;;
esac
sed '/thread_header =/s/@.*@/gthr-posix.h/' -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in
mkdir -v build
cd       build
../configure --build=$(../config.guess) --host=$LFS_TGT --target=$LFS_TGT --prefix=/usr --with-build-sysroot=$LFS --enable-default-pie --enable-default-ssp --disable-nls --disable-multilib --disable-libatomic --disable-libgomp --disable-libquadmath --disable-libsanitizer --disable-libssp --disable-libvtv --enable-languages=c,c++ LDFLAGS_FOR_TARGET=-L$PWD/$LFS_TGT/libgcc
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" DESTDIR=$LFS install
ln -sv gcc $LFS/usr/bin/cc

lfs_finish_package
