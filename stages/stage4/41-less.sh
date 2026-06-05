#!/bin/bash
set -euo pipefail
# less.html — Less-692 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="less-692.tar.gz"

lfs_init_package

./configure --prefix=/usr --sysconfdir=/etc
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" install

lfs_finish_package
