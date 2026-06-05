#!/bin/bash
set -euo pipefail
# lz4.html — Lz4-1.10.0 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="lz4-1.10.0.tar.gz"

lfs_init_package

make -j"${MAKE_JOBS}" BUILD_STATIC=no PREFIX=/usr
make -j"${MAKE_JOBS}" BUILD_STATIC=no PREFIX=/usr install

lfs_finish_package
