#!/bin/bash
set -euo pipefail
# sqlite.html — Sqlite-3510200 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="sqlite-autoconf-3510200.tar.gz"

lfs_init_package

tar -xf ../sqlite-doc-3510200.tar.xz
./configure --prefix=/usr --disable-static --enable-fts{4,5} CPPFLAGS="-D SQLITE_ENABLE_COLUMN_METADATA=1 -D SQLITE_ENABLE_UNLOCK_NOTIFY=1 -D SQLITE_ENABLE_DBSTAT_VTAB=1 -D SQLITE_SECURE_DELETE=1"
make -j"${MAKE_JOBS}" LDFLAGS.rpath=""
make -j"${MAKE_JOBS}" install
install -v -m755 -d /usr/share/doc/sqlite-3.51.2
cp -v -R sqlite-doc-3510200/* /usr/share/doc/sqlite-3.51.2

lfs_finish_package
