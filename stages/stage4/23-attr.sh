#!/bin/bash
set -euo pipefail
# attr.html — Attr-2.5.2 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="attr-2.5.2.tar.gz"

lfs_init_package

./configure --prefix=/usr --disable-static --sysconfdir=/etc --docdir=/usr/share/doc/attr-2.5.2
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" install

lfs_finish_package
