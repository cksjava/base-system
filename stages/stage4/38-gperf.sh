#!/bin/bash
set -euo pipefail
# gperf.html — Gperf-3.3 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="gperf-3.3.tar.gz"

lfs_init_package

./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.3
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" install

lfs_finish_package
