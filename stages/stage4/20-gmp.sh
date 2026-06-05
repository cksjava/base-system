#!/bin/bash
set -euo pipefail
# gmp.html — GMP-6.3.0 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="gmp-6.3.0.tar.xz"

lfs_init_package

ABI=32 ./configure ...
sed -i '/long long t1;/,+1s/()/(...)/' configure
./configure --prefix=/usr --enable-cxx --disable-static --docdir=/usr/share/doc/gmp-6.3.0
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" html
awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log
make -j"${MAKE_JOBS}" install
make -j"${MAKE_JOBS}" install-html

lfs_finish_package
