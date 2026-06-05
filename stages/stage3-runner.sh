#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILDER="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${BUILDER}/lib/lfs-common.sh"

for phase in 23-create-dirs 24-create-files; do
  lfs_run_script "${BUILDER}/phases/${phase}.sh"
done
lfs_run_stage "${SCRIPT_DIR}/stage3"
