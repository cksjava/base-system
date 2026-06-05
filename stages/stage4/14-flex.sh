#!/bin/bash
set -euo pipefail
# flex.html — Flex-2.6.4 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="flex-2.6.4.tar.gz"

lfs_init_package

./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/flex-2.6.4
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" install
ln -sv flex   /usr/bin/lex
ln -sv flex.1 /usr/share/man/man1/lex.1

lfs_finish_package
