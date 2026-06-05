#!/bin/bash
set -euo pipefail
# bison.html — Bison-3.8.2 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="bison-3.8.2.tar.xz"

lfs_init_package

./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.8.2
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" install

lfs_finish_package
