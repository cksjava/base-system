#!/bin/bash
set -euo pipefail
# expat.html — Expat-2.7.4 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="expat-2.7.4.tar.xz"

lfs_init_package

./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/expat-2.7.4
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" install
install -v -m644 doc/*.{html,css} /usr/share/doc/expat-2.7.4

lfs_finish_package
