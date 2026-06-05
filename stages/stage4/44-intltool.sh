#!/bin/bash
set -euo pipefail
# intltool.html — Intltool-0.51.0 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="intltool-0.51.0.tar.gz"

lfs_init_package

sed -i 's:\\\${:\\\$\\{:' intltool-update.in
./configure --prefix=/usr
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" install
install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO

lfs_finish_package
