#!/bin/bash
set -euo pipefail
# LFS ch.5 — cross toolchain (as lfs, ch.4 environment)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/lfs-common.sh"
lfs_run_stage "${SCRIPT_DIR}/stage1" "$(lfs_lfs_rcfile)" 1
