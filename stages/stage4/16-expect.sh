#!/bin/bash
set -euo pipefail
# expect.html — Expect-5.45.4 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="expect5.45.4.tar.gz"

lfs_init_package

python3 -c 'from pty import spawn; spawn(["echo", "ok"])'
patch -Np1 -i ../expect-5.45.4-gcc15-1.patch
./configure --prefix=/usr --with-tcl=/usr/lib --enable-shared --disable-rpath --mandir=/usr/share/man --with-tclinclude=/usr/include
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" install
ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib

lfs_finish_package
