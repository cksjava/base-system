#!/bin/bash
set -euo pipefail
# procps-ng.html — Procps-ng-4.0.6 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="procps-ng-4.0.6.tar.xz"

lfs_init_package

./configure --prefix=/usr --docdir=/usr/share/doc/procps-ng-4.0.6 --disable-static --disable-kill --enable-watch8bit --with-systemd
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" install

lfs_finish_package
