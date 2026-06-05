#!/bin/bash
set -euo pipefail
# bc.html — Bc-7.0.3 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="bc-7.0.3.tar.xz"

lfs_init_package

CC='gcc -std=c99' ./configure --prefix=/usr -G -O3 -r
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" install

lfs_finish_package
