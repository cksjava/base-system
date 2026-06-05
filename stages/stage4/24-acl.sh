#!/bin/bash
set -euo pipefail
# acl.html — Acl-2.3.2 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="acl-2.3.2.tar.xz"

lfs_init_package

./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/acl-2.3.2
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" install

lfs_finish_package
