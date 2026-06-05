#!/bin/bash
set -euo pipefail
# setuptools.html — Setuptools-82.0.0 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="setuptools-82.0.0.tar.gz"

lfs_init_package

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist setuptools

lfs_finish_package
