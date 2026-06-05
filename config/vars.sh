# shellcheck shell=bash
# Load defaults, then machine-specific UUIDs from build.conf (if present).

_CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${_CONFIG_DIR}/vars.defaults.sh"

_BUILD_CONF="${_CONFIG_DIR}/build.conf"
if [[ -f "${_BUILD_CONF}" ]]; then
  # shellcheck disable=SC1090
  source "${_BUILD_CONF}"
fi

export LFS="${LFS:-${LFS_DEFAULT}}"
