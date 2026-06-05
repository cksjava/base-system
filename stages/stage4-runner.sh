#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/lfs-common.sh"
lfs_run_stage "${SCRIPT_DIR}/stage4"
