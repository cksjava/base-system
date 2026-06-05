#!/bin/bash
set -euo pipefail
# BLFS postlfs/profile.html — system-wide bash startup files

BUILDER="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE="${BUILDER}/static/postlfs/profile"
# shellcheck disable=SC1091
source "${BUILDER}/lib/lfs-common.sh"

lfs_script_guard

install -d -m755 /etc/profile.d

install -m644 "${PROFILE}/etc-profile" /etc/profile
install -m644 "${PROFILE}/extrapaths.sh" /etc/profile.d/extrapaths.sh
install -m644 "${PROFILE}/readline.sh" /etc/profile.d/readline.sh
install -m644 "${PROFILE}/umask.sh" /etc/profile.d/umask.sh
install -m644 "${PROFILE}/i18n.sh" /etc/profile.d/i18n.sh
install -m644 "${PROFILE}/etc-bashrc" /etc/bashrc

install -m644 "${PROFILE}/skel-bash_profile" /etc/skel/.bash_profile
install -m644 "${PROFILE}/skel-profile" /etc/skel/.profile
install -m644 "${PROFILE}/skel-bashrc" /etc/skel/.bashrc
install -m644 "${PROFILE}/skel-bash_logout" /etc/skel/.bash_logout

for homedir in /root /home/*; do
  [[ -d "${homedir}" ]] || continue
  for f in .bash_profile .profile .bashrc .bash_logout; do
    if [[ ! -e "${homedir}/${f}" ]]; then
      install -m644 "/etc/skel/${f}" "${homedir}/${f}"
    fi
  done
done

if command -v dircolors >/dev/null; then
  dircolors -p >/etc/dircolors
fi

