#!/bin/bash
set -euo pipefail
# xml-parser.html — XML::Parser-2.47 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="XML-Parser-2.47.tar.gz"

lfs_init_package

perl Makefile.PL
make -j"${MAKE_JOBS}"
make -j"${MAKE_JOBS}" install

lfs_finish_package
