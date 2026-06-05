#!/bin/bash
set -euo pipefail
# tar.html — Tar-1.35 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="tar-1.35.tar.xz"

lfs_init_package

FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" install
make -j"${MAKE_JOBS}" -C doc install-html docdir=/usr/share/doc/tar-1.35

lfs_finish_package
