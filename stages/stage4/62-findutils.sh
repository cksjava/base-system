#!/bin/bash
set -euo pipefail
# findutils.html — Findutils-4.10.0 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="findutils-4.10.0.tar.xz"

lfs_init_package

./configure --prefix=/usr --localstatedir=/var/lib/locate
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" install

lfs_finish_package
