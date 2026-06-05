#!/bin/bash
set -euo pipefail
# readline.html — Readline-8.3 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="readline-8.3.tar.gz"

lfs_init_package

sed -i '/MV.*old/d' Makefile.in
sed -i '/{OLDSUFF}/c:' support/shlib-install
sed -i 's/-Wl,-rpath,[^ ]*//' support/shobj-conf
sed -e '270a else chars_avail = 1;' -e '288i\   result = -1;' -i.orig input.c
./configure --prefix=/usr --disable-static --with-curses --docdir=/usr/share/doc/readline-8.3
make -j"${MAKE_JOBS}" SHLIB_LIBS="-lncursesw"
make -j"${MAKE_JOBS}" install
install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.3

lfs_finish_package
