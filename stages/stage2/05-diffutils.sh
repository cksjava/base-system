#!/bin/bash
set -euo pipefail
# diffutils.html — Diffutils-3.12 (LFS ch.06, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="diffutils-3.12.tar.xz"

lfs_init_package

./configure --prefix=/usr --host=$LFS_TGT gl_cv_func_strcasecmp_works=y --build=$(./build-aux/config.guess)
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" DESTDIR=$LFS install

lfs_finish_package
