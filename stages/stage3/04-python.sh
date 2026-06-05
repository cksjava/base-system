#!/bin/bash
set -euo pipefail
# Python.html — Python-3.14.3 (LFS ch.07, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="Python-3.14.3.tar.xz"

lfs_init_package

./configure --prefix=/usr --enable-shared --without-ensurepip --without-static-libpython
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" install

lfs_finish_package
