#!/bin/bash
set -euo pipefail
# iproute2.html — IPRoute2-6.18.0 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="iproute2-6.18.0.tar.xz"

lfs_init_package

sed -i /ARPD/d Makefile
rm -fv man/man8/arpd.8
make -j"${MAKE_JOBS}" NETNS_RUN_DIR=/run/netns
make -j"${MAKE_JOBS}" SBINDIR=/usr/sbin install
install -vDm644 COPYING README* -t /usr/share/doc/iproute2-6.18.0

lfs_finish_package
