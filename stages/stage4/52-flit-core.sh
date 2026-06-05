#!/bin/bash
set -euo pipefail
# flit-core.html — Flit-Core-3.12.0 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="flit_core-3.12.0.tar.gz"

lfs_init_package

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist flit_core

lfs_finish_package
