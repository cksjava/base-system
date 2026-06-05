#!/bin/bash
set -euo pipefail
# iana-etc.html — Iana-Etc-20260202 (LFS ch.08, generated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/lfs-common.sh"

PKG_TARBALL="iana-etc-20260202.tar.gz"

lfs_init_package

cp -v services protocols /etc

lfs_finish_package
