#!/bin/bash
set -euo pipefail
# automake.html — Automake-1.18.1 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="automake-1.18.1.tar.xz"

lfs_init_package

./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.18.1
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" install

lfs_finish_package
