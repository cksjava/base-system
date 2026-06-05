# shellcheck shell=bash
# Load defaults, then machine-specific UUIDs from build.conf (if present).

_CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${_CONFIG_DIR}/vars.defaults.sh"

_BUILD_CONF="${_CONFIG_DIR}/build.conf"
if [[ -r "${_BUILD_CONF}" ]]; then
  # shellcheck disable=SC1090
  source "${_BUILD_CONF}"
elif [[ -f "${_BUILD_CONF}" ]]; then
  # ch.5–6 runs as lfs; build.conf is root-owned until perms are fixed (see lfs_fix_build_conf_perms)
  :
fi

export LFS="${LFS:-${LFS_DEFAULT}}"
