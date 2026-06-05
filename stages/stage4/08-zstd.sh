#!/bin/bash
set -euo pipefail
# zstd.html — Zstd-1.5.7 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="zstd-1.5.7.tar.gz"

lfs_init_package

make -j"${MAKE_JOBS}" prefix=/usr
make -j"${MAKE_JOBS}" prefix=/usr install
rm -v /usr/lib/libzstd.a

lfs_finish_package
