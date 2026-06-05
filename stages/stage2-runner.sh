#!/bin/bash
set -euo pipefail
# LFS ch.6 — temporary tools (as lfs, ch.4 environment)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/lfs-common.sh"
lfs_run_stage "${SCRIPT_DIR}/stage2" "$(lfs_lfs_rcfile)" 1
