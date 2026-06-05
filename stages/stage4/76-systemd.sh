#!/bin/bash
set -euo pipefail
# systemd.html — Systemd-259.1 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="systemd-259.1.tar.gz"

lfs_init_package

sed -e 's/GROUP="render"/GROUP="video"/' -e 's/GROUP="sgx", //' -i rules.d/50-udev-default.rules.in
mkdir -p build
cd       build
meson setup .. --prefix=/usr --buildtype=release -D default-dnssec=no -D firstboot=false -D install-tests=false -D ldconfig=false -D sysusers=false -D rpmmacrosdir=no -D homed=disabled -D man=disabled -D mode=release -D pamconfdir=no -D dev-kvm-mode=0660 -D nobody-group=nogroup -D sysupdate=disabled -D ukify=disabled -D docdir=/usr/share/doc/systemd-259.1
ninja
ninja install
tar -xf ../../systemd-man-pages-259.1.tar.xz --no-same-owner --strip-components=1 -C /usr/share/man
systemd-machine-id-setup

lfs_finish_package
