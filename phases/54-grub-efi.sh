#!/bin/bash
set -euo pipefail
# BLFS postlfs/grub-efi.html — EFI platform modules (LFS grub is BIOS-only)

BUILDER="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "${BUILDER}/lib/lfs-common.sh"

GRUB_TARBALL="grub-2.14.tar.xz"
GRUB_DIR="grub-2.14"

lfs_script_guard

cd "${SOURCES}"
if [[ ! -d "${GRUB_DIR}" ]]; then
  tar -xf "${GRUB_TARBALL}"
fi
cd "${GRUB_DIR}"

unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS

if [[ ! -f Makefile ]] || ! grep -q 'platform=efi' config.status 2>/dev/null; then
  make distclean 2>/dev/null || true
  ./configure --prefix=/usr \
    --sysconfdir=/etc \
    --disable-efiemu \
    --with-platform=efi \
    --target=x86_64 \
    --disable-werror
fi

make -j"${MAKE_JOBS}"
make -C grub-core install

