#!/bin/bash
set -euo pipefail
# wheel.html — Wheel-0.46.3 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="wheel-0.46.3.tar.gz"

lfs_init_package

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist wheel

lfs_finish_package
