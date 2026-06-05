#!/bin/bash
set -euo pipefail
# ncurses.html — Ncurses-6.6 (LFS ch.06, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="ncurses-6.6.tar.gz"

lfs_init_package

mkdir build
pushd build
../configure --prefix=$LFS/tools AWK=gawk
make -j"${MAKE_JOBS}" -C include
make -j"${MAKE_JOBS}" -C progs tic
install progs/tic $LFS/tools/bin
popd
./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess) --mandir=/usr/share/man --with-manpage-format=normal --with-shared --without-normal --with-cxx-shared --without-debug --without-ada --disable-stripping AWK=gawk
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" DESTDIR=$LFS install
ln -sv libncursesw.so $LFS/usr/lib/libncurses.so
sed -e 's/^#if.*XOPEN.*$/#if 1/' -i $LFS/usr/include/curses.h

lfs_finish_package
