#!/bin/bash
# Master LFS 13.0-systemd builder — unattended full-system build.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ROOT

require_root() {
  if [[ "$(id -u)" -ne 0 ]]; then
    echo "lfs-build.sh must be run as root." >&2
    exit 1
  fi
}

lfs_source_builder_libs() {
  # shellcheck disable=SC1091
  source "${ROOT}/config/vars.sh"
  # shellcheck disable=SC1091
  source "${ROOT}/lib/lfs-configure.sh"
  lfs_ensure_build_config
  # shellcheck disable=SC1091
  source "${ROOT}/config/vars.sh"
  # shellcheck disable=SC1091
  source "${ROOT}/lib/lfs-common.sh"
}

BUILD_LOG=""
log() { echo "[$(date -Iseconds)] $*" | tee -a "${BUILD_LOG}"; }

run_phase() {
  local script="${ROOT}/phases/$1.sh"
  if [[ ! -f "${script}" ]]; then
    log "skip missing phase: $1"
    return 0
  fi
  log "phase: $1"
  lfs_run_script "${script}"
}

mount_lfs() {
  lfs_mount_root
  mount_opts=$(findmnt -no OPTIONS "${LFS}" 2>/dev/null || true)
  if grep -q noexec <<<"${mount_opts}"; then
    log "remounting ${LFS} with exec"
    mount -o remount,exec "${LFS}"
  fi
}

prepare_mounted_build() {
  mount_lfs
  lfs_bind_mount_sources_on_lfs
}

materialize_sources() {
  log "sources: umount bind mount, copy host cache onto LFS partition"
  lfs_ensure_sources_on_partition
  init_build_log
}

init_build_log() {
  BUILD_LOG="${SOURCES}/.lfs-build-logs/master.log"
  mkdir -p "${LOG_DIR}"
}

start_build_command() {
  prepare_mounted_build
  init_build_log
}

copy_builder_to_sources() {
  mkdir -p "${LFS}/sources"
  rsync -a --delete \
    --exclude '13.0' \
    --exclude 'LFS-BOOK-13.0.tar.xz' \
    --exclude '.git' \
    "${ROOT}/" "${LFS}/sources/builder/"
}

usage() {
  cat <<EOF
Usage: sudo $0 [command]

Commands:
  configure    (Re)create config/build.conf from partition prompts
  all          Full build (default)
  host         Host prep only (mount, layout, lfs user, environment)
  stage1       Chapter 5 cross toolchain (as lfs)
  stage2       Chapter 6 temporary tools (as lfs)
  chroot-prep  Chapter 7 pre-chroot phases
  stage3       Chapter 7 packages inside chroot
  stage4       Chapter 8 final system inside chroot
  system       Chapter 9–10 system configuration
  sync         Copy builder tree into \$LFS/sources/builder

Environment:
  LFS_YES=1           Accept all configuration defaults without prompting
  LFS_RECONFIGURE=1   Force re-run configuration prompts

Sources (differs from LFS book ch.3):
  Book: mkdir \$LFS/sources, chmod a+wt, wget into the mounted partition.
  Here: wget into <parent-of-builder>/sources; after mount, bind-mount
  that cache at \$LFS/sources (stages 1–2, like ch.7 kernfs); before chroot,
  umount and copy onto the partition (real \$LFS/sources per the book).

Regenerate scripts: ./lfs_parser.py
EOF
}

cmd="${1:-all}"

require_root

case "${cmd}" in
  -h|--help|help)
    usage
    exit 0
    ;;
  configure)
    # shellcheck disable=SC1091
    source "${ROOT}/config/vars.sh"
    # shellcheck disable=SC1091
    source "${ROOT}/lib/lfs-configure.sh"
    lfs_interactive_configure 1
    exit 0
    ;;
esac

# Host-side sources cache (sibling to builder): ch.3 wget-list-systemd download.
if [[ "${cmd}" != configure ]]; then
  # shellcheck disable=SC1091
  source "${ROOT}/lib/lfs-sources.sh"
  lfs_ensure_sources_cache
fi

lfs_source_builder_libs

case "${cmd}" in
  sync)
    start_build_command
    copy_builder_to_sources
    ;;
  host)
    start_build_command
    run_phase 10-create-min-layout
    run_phase 11-add-lfs-user
    run_phase 12-lfs-environment
    ;;
  stage1)
    start_build_command
    copy_builder_to_sources
    lfs_run_as_lfs "${LFS}/sources/builder/stages/stage1-runner.sh"
    ;;
  stage2)
    start_build_command
    lfs_run_as_lfs "${LFS}/sources/builder/stages/stage2-runner.sh"
    ;;
  chroot-prep)
    start_build_command
    materialize_sources
    run_phase 20-change-ownership
    run_phase 21-kernfs
    ;;
  stage3)
    start_build_command
    materialize_sources
    lfs_chroot_run "${LFS}/sources/builder/stages/stage3-runner.sh"
    ;;
  stage4)
    start_build_command
    materialize_sources
    lfs_chroot_run "${LFS}/sources/builder/stages/stage4-runner.sh"
    ;;
  system)
    start_build_command
    materialize_sources
    lfs_chroot_run "${LFS}/sources/builder/lfs-chroot-build.sh"
    ;;
  all)
    start_build_command
    copy_builder_to_sources
    log "=== LFS full build start ==="
    run_phase 10-create-min-layout
    run_phase 11-add-lfs-user
    run_phase 12-lfs-environment
    lfs_run_as_lfs "${LFS}/sources/builder/stages/stage1-runner.sh"
    lfs_run_as_lfs "${LFS}/sources/builder/stages/stage2-runner.sh"
    materialize_sources
    run_phase 20-change-ownership
    run_phase 21-kernfs
    lfs_chroot_run "${LFS}/sources/builder/lfs-chroot-build.sh"
    log "=== LFS full build finished ==="
    ;;
  *)
    echo "Unknown command: ${cmd}" >&2
    usage
    exit 1
    ;;
esac
