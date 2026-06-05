#!/bin/bash
set -euo pipefail
# libffi.html — Libffi-3.5.2 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="libffi-3.5.2.tar.gz"

lfs_init_package

./configure --prefix=/usr --disable-static --with-gcc-arch=native
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" install

lfs_finish_package
