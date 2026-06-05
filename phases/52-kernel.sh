#!/bin/bash
set -euo pipefail
# LFS chapter 10 kernel — non-interactive defconfig for the build architecture

BUILDER="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "${BUILDER}/lib/lfs-common.sh"
# shellcheck disable=SC1091
source "${BUILDER}/config/vars.sh"

: "${LINUX_DIR:?}"
: "${KERNEL_RELEASE:?}"

lfs_script_guard

cd "${SOURCES}"
if [[ ! -f "${LINUX_TARBALL}" ]]; then
  echo "Missing ${SOURCES}/${LINUX_TARBALL}" >&2
  exit 1
fi

if [[ ! -d "${LINUX_DIR}" ]]; then
  tar -xf "${LINUX_TARBALL}"
fi
cd "${LINUX_DIR}"

make mrproper
make defconfig

make -j"${MAKE_JOBS}"
make modules_install

if mountpoint -q /boot 2>/dev/null || grep -q '[[:space:]]/boot[[:space:]]' /etc/fstab 2>/dev/null; then
  mount /boot
fi

install -vm644 arch/x86/boot/bzImage "/boot/vmlinuz-${KERNEL_RELEASE}"
install -vm644 System.map "/boot/System.map-${LINUX_VERSION}"
install -vm644 .config "/boot/config-${LINUX_VERSION}"
cp -r Documentation -T "/usr/share/doc/${LINUX_DIR}"

chown -R 0:0 "${SOURCES}/${LINUX_DIR}"

