#!/bin/bash
set -euo pipefail
# pkgconf.html — Pkgconf-2.5.1 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="pkgconf-2.5.1.tar.xz"

lfs_init_package

./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/pkgconf-2.5.1
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" install
ln -sv pkgconf   /usr/bin/pkg-config
ln -sv pkgconf.1 /usr/share/man/man1/pkg-config.1

lfs_finish_package
