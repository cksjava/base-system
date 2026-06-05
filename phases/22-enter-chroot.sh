#!/bin/bash
set -euo pipefail
# Phase: chroot marker (chapter 07)
# Actual non-interactive chroot is performed by lfs-build.sh via lfs_chroot_run().

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/lfs-common.sh"

lfs_script_guard

echo "Chroot will be entered by the master builder (non-interactive)."
