#!/bin/bash
set -euo pipefail
# libtool.html — Libtool-2.5.4 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="libtool-2.5.4.tar.xz"

lfs_init_package

./configure --prefix=/usr
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" install
rm -fv /usr/lib/libltdl.a

lfs_finish_package
