#!/bin/bash
set -euo pipefail
# LFS ch.9 — /etc/locale.conf (config/build.conf)

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/lfs-common.sh"

lfs_script_guard

: "${LANG:?}"

{
  echo "LANG=${LANG}"
  [[ -n "${LC_COLLATE:-}" ]] && echo "LC_COLLATE=${LC_COLLATE}"
  [[ -n "${LC_TIME:-}" ]] && echo "LC_TIME=${LC_TIME}"
} >/etc/locale.conf

localectl set-locale "LANG=${LANG}"
[[ -n "${LC_COLLATE:-}" ]] && localectl set-locale "LC_COLLATE=${LC_COLLATE}"
[[ -n "${LC_TIME:-}" ]] && localectl set-locale "LC_TIME=${LC_TIME}"

# Ensure locale data exists (glibc installs all locales in our build).
if ! locale -a 2>/dev/null | grep -qi "^${LANG}$"; then
  echo "WARNING: ${LANG} not in locale -a — may need localedef or glibc locales" >&2
fi
