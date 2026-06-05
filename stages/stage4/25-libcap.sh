#!/bin/bash
set -euo pipefail
# libcap.html — Libcap-2.77 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="libcap-2.77.tar.xz"

lfs_init_package

sed -i '/install -m.*STA/d' libcap/Makefile
make -j"${MAKE_JOBS}" prefix=/usr lib=lib
make -j"${MAKE_JOBS}" prefix=/usr lib=lib install

lfs_finish_package
