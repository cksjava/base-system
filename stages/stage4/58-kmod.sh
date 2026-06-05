#!/bin/bash
set -euo pipefail
# kmod.html — Kmod-34.2 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="kmod-34.2.tar.xz"

lfs_init_package

mkdir -p build
cd       build
meson setup --prefix=/usr .. --buildtype=release -D manpages=false
ninja
ninja install

lfs_finish_package
