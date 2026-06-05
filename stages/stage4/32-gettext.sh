#!/bin/bash
set -euo pipefail
# gettext.html — Gettext-1.0 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="gettext-1.0.tar.xz"

lfs_init_package

./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/gettext-1.0
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" install
chmod -v 0755 /usr/lib/preloadable_libintl.so

lfs_finish_package
