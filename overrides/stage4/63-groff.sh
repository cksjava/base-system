#!/bin/bash
set -euo pipefail
# groff — PAGE size from config/build.conf (LFS ch.8)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="groff-1.23.0.tar.gz"
: "${GROFF_PAPER_SIZE:?GROFF_PAPER_SIZE not set — run lfs-build.sh configure}"

lfs_init_package

PAGE="${GROFF_PAPER_SIZE}" ./configure --prefix=/usr
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" install
echo "${GROFF_PAPER_SIZE}" >/etc/papersize

lfs_finish_package
