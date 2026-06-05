#!/bin/bash
set -euo pipefail
# man-pages.html — Man-pages-6.17 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="man-pages-6.17.tar.xz"

lfs_init_package

rm -v man3/crypt*
make -j"${MAKE_JOBS}" -R GIT=false prefix=/usr install

lfs_finish_package
