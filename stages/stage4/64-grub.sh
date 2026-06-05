#!/bin/bash
set -euo pipefail
# grub.html — GRUB-2.14 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="grub-2.14.tar.xz"

lfs_init_package

unset {C,CPP,CXX,LD}FLAGS
sed 's/--image-base/--nonexist-linker-option/' -i configure
./configure --prefix=/usr --sysconfdir=/etc --disable-efiemu --disable-werror
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" install

lfs_finish_package
