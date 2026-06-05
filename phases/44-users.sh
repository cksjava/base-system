#!/bin/bash
set -euo pipefail
# LFS ch.11 — root and normal user passwords (config/build.conf)

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/lfs-common.sh"

lfs_script_guard

: "${SYSTEM_USER:?}"
: "${ROOT_PASSWORD:?}"
: "${USER_PASSWORD:?}"

echo "root:${ROOT_PASSWORD}" | chpasswd

if id "${SYSTEM_USER}" &>/dev/null; then
  echo "${SYSTEM_USER}:${USER_PASSWORD}" | chpasswd
else
  useradd -m -G tty,input,video,audio \
    -s /bin/bash "${SYSTEM_USER}"
  echo "${SYSTEM_USER}:${USER_PASSWORD}" | chpasswd
  install -d -m700 "/home/${SYSTEM_USER}"
  chown -R "${SYSTEM_USER}:${SYSTEM_USER}" "/home/${SYSTEM_USER}"
  for f in .bash_profile .profile .bashrc .bash_logout; do
    if [[ -f "/etc/skel/${f}" && ! -e "/home/${SYSTEM_USER}/${f}" ]]; then
      install -m644 "/etc/skel/${f}" "/home/${SYSTEM_USER}/${f}"
      chown "${SYSTEM_USER}:${SYSTEM_USER}" "/home/${SYSTEM_USER}/${f}"
    fi
  done
fi
