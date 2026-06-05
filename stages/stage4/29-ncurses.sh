#!/bin/bash
set -euo pipefail
# ncurses.html — Ncurses-6.6 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="ncurses-6.6.tar.gz"

lfs_init_package

./configure --prefix=/usr --mandir=/usr/share/man --with-shared --without-debug --without-normal --with-cxx-shared --enable-pc-files --with-pkg-config-libdir=/usr/lib/pkgconfig
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" DESTDIR=$PWD/dest install
sed -e 's/^#if.*XOPEN.*$/#if 1/' -i dest/usr/include/curses.h
cp --remove-destination -av dest/* /
for lib in ncurses form panel menu ; do
ln -sfv lib${lib}w.so /usr/lib/lib${lib}.so
ln -sfv ${lib}w.pc    /usr/lib/pkgconfig/${lib}.pc
done
ln -sfv libncursesw.so /usr/lib/libcurses.so
cp -v -R doc -T /usr/share/doc/ncurses-6.6
make -j"${MAKE_JOBS}" distclean
./configure --prefix=/usr --with-shared --without-normal --without-debug --without-cxx-binding --with-abi-version=5
make -j"${MAKE_JOBS}" sources libs
cp -av lib/lib*.so.5* /usr/lib

lfs_finish_package
