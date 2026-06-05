#!/bin/bash
set -euo pipefail
# gettext.html — Gettext-1.0 (LFS ch.07, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="gettext-1.0.tar.xz"

lfs_init_package

./configure --disable-shared
make -j"${MAKE_JOBS}"
cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin

lfs_finish_package
