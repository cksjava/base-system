#!/bin/bash
set -euo pipefail
# kbd.html — Kbd-2.9.0 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="kbd-2.9.0.tar.xz"

lfs_init_package

patch -Np1 -i ../kbd-2.9.0-backspace-1.patch
sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in
./configure --prefix=/usr --disable-vlock
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" install
cp -R -v docs/doc -T /usr/share/doc/kbd-2.9.0

lfs_finish_package
