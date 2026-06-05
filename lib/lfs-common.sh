# Shared LFS build helpers (sourced by package and phase scripts).
# shellcheck shell=bash

_BUILDER_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_BUILDER_ROOT="$(cd "${_BUILDER_LIB}/.." && pwd)"
# shellcheck disable=SC1091
[[ -f "${_BUILDER_LIB}/lfs-disk.sh" ]] && source "${_BUILDER_LIB}/lfs-disk.sh"
# shellcheck disable=SC1091
[[ -f "${_BUILDER_ROOT}/config/vars.sh" ]] && source "${_BUILDER_ROOT}/config/vars.sh"

: "${LFS:?LFS must be set}"
LFS_TGT="${LFS_TGT:-$(uname -m)-lfs-linux-gnu}"
export LFS_TGT

if [[ -d /sources/builder && ! -d "${LFS}/usr" ]]; then
  LFS=/
  SOURCES=/sources
else
  SOURCES="${LFS}/sources"
fi
export LFS SOURCES

MAKE_JOBS="$(nproc)"
export MAKE_JOBS

LOG_DIR="${SOURCES}/.lfs-build-logs"
mkdir -p "${LOG_DIR}" "${SOURCES}"

# ch.5–6 runs as lfs; build.conf must be group-readable (not world-readable).
lfs_fix_build_conf_perms() {
  local conf
  for conf in \
    "${ROOT:-}/config/build.conf" \
    "${_BUILDER_ROOT}/config/build.conf" \
    "${LFS:-}/sources/builder/config/build.conf"; do
    [[ -f "${conf}" ]] || continue
    if getent group lfs >/dev/null 2>&1; then
      chgrp lfs "${conf}" 2>/dev/null || true
      chmod 640 "${conf}" 2>/dev/null || true
    fi
  done
}

# Name of the script being executed (package or phase .sh).
SCRIPT_NAME="$(basename "${BASH_SOURCE[1]:-${BASH_SOURCE[0]}}")"

lfs_script_record_file() {
  echo "${LOG_DIR}/${1:-${SCRIPT_NAME}}.record"
}

lfs_script_transcript_file() {
  echo "${LOG_DIR}/${1:-${SCRIPT_NAME}}.log"
}

lfs_script_read_field() {
  local file=$1 key=$2
  [[ -f "${file}" ]] || return 1
  sed -n "s/^${key}=//p" "${file}" | head -1
}

lfs_script_is_successful() {
  local name=${1:-${SCRIPT_NAME}}
  local record
  record="$(lfs_script_record_file "${name}")"
  [[ -f "${record}" ]] || return 1
  [[ "$(lfs_script_read_field "${record}" status)" == success ]]
}

lfs_script_write_record() {
  local name=$1
  shift
  local record tmp
  record="$(lfs_script_record_file "${name}")"
  tmp="$(mktemp)"
  {
    echo "script=${name}"
    for line in "$@"; do
      echo "${line}"
    done
  } >"${tmp}"
  mv -f "${tmp}" "${record}"
}

lfs_script_append_journal() {
  local line=$1
  echo "${line}" >>"${LOG_DIR}/journal.log"
}

lfs_script_print_skip() {
  local name=${1:-${SCRIPT_NAME}}
  local record
  record="$(lfs_script_record_file "${name}")"
  echo "Skipping ${name} (already completed successfully)"
  if [[ -f "${record}" ]]; then
    echo "  started:  $(lfs_script_read_field "${record}" started)"
    echo "  finished: $(lfs_script_read_field "${record}" finished)"
    echo "  duration: $(lfs_script_read_field "${record}" duration_seconds)s"
    echo "  record:   ${record}"
  fi
}

lfs_script_begin() {
  local name=${1:-${SCRIPT_NAME}}
  local started
  started="$(date -Iseconds)"
  lfs_script_write_record "${name}" \
    status=running \
    "started=${started}"
  echo "==> ${name} started at ${started}"
}

lfs_script_mark_success() {
  local name=${1:-${SCRIPT_NAME}}
  local record finished started start_s end_s duration
  record="$(lfs_script_record_file "${name}")"
  finished="$(date -Iseconds)"
  started="$(lfs_script_read_field "${record}" started 2>/dev/null || true)"
  start_s=$(date -d "${started}" +%s 2>/dev/null || echo 0)
  end_s=$(date +%s)
  duration=$((end_s - start_s))
  if (( duration < 0 )); then
    duration=0
  fi
  lfs_script_write_record "${name}" \
    status=success \
    "started=${started:-${finished}}" \
    "finished=${finished}" \
    "duration_seconds=${duration}"
  lfs_script_append_journal "$(date -Iseconds) SUCCESS ${name} duration=${duration}s"
  echo "==> ${name} finished at ${finished} (${duration}s)"
}

lfs_script_mark_failed() {
  local name=${1:-${SCRIPT_NAME}}
  local exit_code=${2:-1}
  local record finished started start_s end_s duration
  record="$(lfs_script_record_file "${name}")"
  finished="$(date -Iseconds)"
  started="$(lfs_script_read_field "${record}" started 2>/dev/null || true)"
  start_s=$(date -d "${started}" +%s 2>/dev/null || echo 0)
  end_s=$(date +%s)
  duration=$((end_s - start_s))
  if (( duration < 0 )); then
    duration=0
  fi
  lfs_script_write_record "${name}" \
    status=failed \
    "started=${started:-${finished}}" \
    "finished=${finished}" \
    "duration_seconds=${duration}" \
    "exit_code=${exit_code}"
  lfs_script_append_journal "$(date -Iseconds) FAILED ${name} exit=${exit_code} duration=${duration}s"
  echo "==> ${name} FAILED at ${finished} (exit ${exit_code}, ${duration}s)" >&2
}

lfs_script_on_exit() {
  local rc=$1
  trap - EXIT
  if (( rc == 0 )); then
    lfs_script_mark_success
  else
    lfs_script_mark_failed "${SCRIPT_NAME}" "${rc}"
  fi
  exit "${rc}"
}

# Idempotent entry for phase / post-lfs scripts: skip if success, else track timing.
lfs_script_guard() {
  if lfs_script_is_successful; then
    lfs_script_print_skip
    exit 0
  fi
  lfs_script_begin
  trap 'lfs_script_on_exit $?' EXIT
}

# Legacy names used by package scripts.
lfs_skip_if_done() {
  if lfs_script_is_successful; then
    lfs_script_print_skip
    exit 0
  fi
  lfs_script_begin
  trap 'lfs_script_on_exit $?' EXIT
}

lfs_mark_done() {
  trap - EXIT
  lfs_script_mark_success
}

lfs_lfs_home() {
  getent passwd lfs | cut -d: -f6
}

lfs_lfs_rcfile() {
  echo "$(lfs_lfs_home)/.bashrc"
}

lfs_run_script() {
  local script=$1
  shift
  local name log
  name="$(basename "${script}")"

  if lfs_script_is_successful "${name}"; then
    lfs_script_print_skip "${name}"
    return 0
  fi

  export SCRIPT_NAME="${name}"
  log="$(lfs_script_transcript_file "${name}")"
  echo "==> Running ${script} (transcript: ${log})"
  set +e
  { bash "$@" "${script}"; } > >(tee -a "${log}") 2>&1
  local rc=${PIPESTATUS[0]}
  set -e
  return "${rc}"
}

# Ch.5–6 package builds must run as lfs with ~/.bashrc (PATH, CONFIG_SITE, set +h).
lfs_run_script_as_lfs() {
  local script=$1
  shift
  local name log lfs_home rcfile
  name="$(basename "${script}")"
  lfs_home="$(lfs_lfs_home)"

  if [[ -z "${lfs_home}" ]] || ! getent passwd lfs >/dev/null 2>&1; then
    echo "lfs user does not exist — run phase 11-add-lfs-user first" >&2
    return 1
  fi

  if lfs_script_is_successful "${name}"; then
    lfs_script_print_skip "${name}"
    return 0
  fi

  rcfile="$(lfs_lfs_rcfile)"
  export SCRIPT_NAME="${name}"
  log="$(lfs_script_transcript_file "${name}")"
  echo "==> Running ${script} as lfs (transcript: ${log})"
  set +e
  {
    if [[ "$(id -u)" -eq 0 ]]; then
      if ! command -v runuser >/dev/null 2>&1; then
        echo "runuser is required to drop privileges to lfs" >&2
        exit 1
      fi
      runuser -u lfs -- bash --rcfile "${rcfile}" "$@" "${script}"
    elif [[ "$(id -un)" == lfs ]]; then
      bash --rcfile "${rcfile}" "$@" "${script}"
    else
      echo "refusing to run ${script} as $(id -un); expected root or lfs" >&2
      exit 1
    fi
  } > >(tee -a "${log}") 2>&1
  local rc=${PIPESTATUS[0]}
  set -e
  return "${rc}"
}

lfs_pkg_dir_from_tarball() {
  local tarball=$1
  local archive="${SOURCES}/${tarball}"
  local first top base suf

  [[ -f "${archive}" ]] || archive="${tarball}"

  first="$(tar -tf "${archive}" 2>/dev/null | head -1)"
  first="${first//$'\r'/}"
  if [[ -n "${first}" ]]; then
    if [[ "${first}" == */* ]]; then
      top="${first%%/*}"
    else
      top="${first%/}"
    fi
    if [[ -n "${top}" && "${top}" != "." ]]; then
      echo "${top}"
      return 0
    fi
  fi

  base="${tarball##*/}"
  for suf in .tar.xz .tar.gz .tar.bz2 .tar.Z .tgz; do
    if [[ "${base}" == *"${suf}" ]]; then
      echo "${base%"${suf}"}"
      return 0
    fi
  done
  echo "${base%.tar}"
}

lfs_init_package() {
  : "${PKG_TARBALL:?PKG_TARBALL required}"
  lfs_skip_if_done
  cd "${SOURCES}"
  if [[ ! -f "${PKG_TARBALL}" ]]; then
    echo "Missing tarball: ${SOURCES}/${PKG_TARBALL}" >&2
    exit 1
  fi
  if [[ -z "${PKG_DIR:-}" ]]; then
    PKG_DIR="$(lfs_pkg_dir_from_tarball "${PKG_TARBALL}")"
  fi
  export PKG_DIR
  echo "Using source directory: ${PKG_DIR} (from ${PKG_TARBALL})"
  rm -rf "${PKG_DIR}"
  tar -xf "${PKG_TARBALL}"
  if [[ ! -d "${PKG_DIR}" ]]; then
    echo "Expected directory ${SOURCES}/${PKG_DIR} after extracting ${PKG_TARBALL}" >&2
    exit 1
  fi
  cd "${PKG_DIR}"
}

lfs_finish_package() {
  cd "${SOURCES}"
  if [[ -n "${PKG_DIR:-}" ]]; then
    rm -rf "${PKG_DIR}"
  fi
  lfs_mark_done
}

lfs_run_stage() {
  local stage_dir=$1
  local rcfile=${2:-}
  local as_lfs=${3:-0}
  shopt -s nullglob
  local scripts=("${stage_dir}"/*.sh)
  if ((${#scripts[@]} == 0)); then
    echo "No scripts in ${stage_dir}" >&2
    exit 1
  fi
  for script in "${scripts[@]}"; do
    if [[ "${as_lfs}" -eq 1 ]]; then
      if [[ -n "${rcfile}" ]]; then
        lfs_run_script_as_lfs "${script}" --rcfile "${rcfile}"
      else
        lfs_run_script_as_lfs "${script}"
      fi
    elif [[ -n "${rcfile}" ]]; then
      lfs_run_script "${script}" --rcfile "${rcfile}"
    else
      lfs_run_script "${script}"
    fi
  done
}

lfs_write_lfs_bashrc() {
  local home=$1
  cat >"${home}/.bashrc" <<EOF
set +h
umask 022
LFS=${LFS}
LC_ALL=POSIX
LFS_TGT=\$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:\$PATH; fi
PATH=\$LFS/tools/bin:\$PATH
HOST_LD=\$(PATH=/usr/bin:/bin command -v ld)
export LD=\$HOST_LD
CONFIG_SITE=\$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE LD
export MAKEFLAGS=-j\$(nproc)
EOF
  cat >"${home}/.bash_profile" <<'EOF'
case $- in
  *i*) ;;
  *) return ;;
esac
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF
}

lfs_run_as_lfs() {
  local script=$1
  local lfs_home
  lfs_home="$(lfs_lfs_home)"
  lfs_fix_build_conf_perms
  lfs_write_lfs_bashrc "${lfs_home}"
  lfs_run_script_as_lfs "${script}"
}

lfs_chroot_run() {
  local script=$1
  local name log
  name="$(basename "${script}")"

  if lfs_script_is_successful "${name}"; then
    lfs_script_print_skip "${name}"
    return 0
  fi

  export SCRIPT_NAME="${name}"
  log="$(lfs_script_transcript_file "${name}")"
  echo "==> chroot ${script} (transcript: ${log})"
  set +e
  { chroot "${LFS}" /usr/bin/env -i \
      HOME=/root TERM="${TERM:-linux}" \
      PS1='(lfs chroot) \u:\w\$ ' \
      PATH=/usr/bin:/usr/sbin \
      LFS=/ SOURCES=/sources \
      MAKEFLAGS="-j${MAKE_JOBS}" \
      TESTSUITEFLAGS="-j${MAKE_JOBS}" \
      /bin/bash --noprofile --norc "${script}"; } > >(tee -a "${log}") 2>&1
  local rc=${PIPESTATUS[0]}
  set -e
  return "${rc}"
}
