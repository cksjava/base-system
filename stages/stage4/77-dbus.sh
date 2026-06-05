#!/bin/bash
set -euo pipefail
# dbus.html — D-Bus-1.16.2 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="dbus-1.16.2.tar.xz"

lfs_init_package

mkdir build
cd    build
meson setup --prefix=/usr --buildtype=release --wrap-mode=nofallback ..
ninja
ninja install
ln -sfv /etc/machine-id /var/lib/dbus

lfs_finish_package
