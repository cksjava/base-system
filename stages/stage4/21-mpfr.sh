#!/bin/bash
set -euo pipefail
# mpfr.html — MPFR-4.2.2 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="mpfr-4.2.2.tar.xz"

lfs_init_package

./configure --prefix=/usr --disable-static --enable-thread-safe --docdir=/usr/share/doc/mpfr-4.2.2
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" html
make -j"${MAKE_JOBS}" install
make -j"${MAKE_JOBS}" install-html

lfs_finish_package
