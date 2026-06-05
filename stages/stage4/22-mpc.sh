#!/bin/bash
set -euo pipefail
# mpc.html — MPC-1.3.1 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="mpc-1.3.1.tar.gz"

lfs_init_package

./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/mpc-1.3.1
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" html
make -j"${MAKE_JOBS}" install
make -j"${MAKE_JOBS}" install-html

lfs_finish_package
