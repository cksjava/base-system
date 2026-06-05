#!/bin/bash
# Runs inside chroot after host phases 20–21 (non-interactive).
set -euo pipefail

BUILDER="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${BUILDER}/lib/lfs-common.sh"

run_phase() {
  local script="${BUILDER}/phases/$1.sh"
  [[ -f "${script}" ]] || return 0
  lfs_run_script "${script}"
}

run_phase 23-create-dirs
run_phase 24-create-files
lfs_run_stage "${BUILDER}/stages/stage3"
run_phase 30-pkg-mgmt
lfs_run_stage "${BUILDER}/stages/stage4"
run_phase 40-console
run_phase 41-locale
run_phase 42-clock
run_phase 43-network
run_phase 45-devices
run_phase 44-users
run_phase 50-fstab
run_phase 52-kernel
run_phase 53-initramfs
run_phase 54-grub-efi
run_phase 55-grub-boot
run_phase 99-blfs-profile
