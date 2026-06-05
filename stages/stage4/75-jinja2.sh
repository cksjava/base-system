#!/bin/bash
set -euo pipefail
# jinja2.html — Jinja2-3.1.6 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="jinja2-3.1.6.tar.gz"

lfs_init_package

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist Jinja2

lfs_finish_package
