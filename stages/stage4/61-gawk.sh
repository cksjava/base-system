#!/bin/bash
set -euo pipefail
# gawk.html — Gawk-5.3.2 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="gawk-5.3.2.tar.xz"

lfs_init_package

sed -i 's/extras//' Makefile.in
./configure --prefix=/usr
make -j"${MAKE_JOBS}"
rm -f /usr/bin/gawk-5.3.2
make -j"${MAKE_JOBS}" install
ln -sv gawk.1 /usr/share/man/man1/awk.1
install -vDm644 doc/{awkforai.txt,*.{eps,pdf,jpg}} -t /usr/share/doc/gawk-5.3.2

lfs_finish_package
