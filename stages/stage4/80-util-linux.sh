#!/bin/bash
set -euo pipefail
# util-linux.html — Util-linux-2.41.3 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="util-linux-2.41.3.tar.xz"

lfs_init_package

./configure --bindir=/usr/bin --libdir=/usr/lib --runstatedir=/run --sbindir=/usr/sbin --disable-chfn-chsh --disable-login --disable-nologin --disable-su --disable-setpriv --disable-runuser --disable-pylibmount --disable-liblastlog2 --disable-static --without-python ADJTIME_PATH=/var/lib/hwclock/adjtime --docdir=/usr/share/doc/util-linux-2.41.3
make -j"${MAKE_JOBS}"
bash tests/run.sh --srcdir=$PWD --builddir=$PWD
make -j"${MAKE_JOBS}" install

lfs_finish_package
