#!/bin/bash
set -euo pipefail
# GRUB EFI install + grub.cfg (UUID root; no device names in config files)

BUILDER="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "${BUILDER}/config/vars.sh"
# shellcheck disable=SC1091
source "${BUILDER}/lib/lfs-common.sh"

lfs_require_disk_config
: "${KERNEL_RELEASE:?}"
: "${ESP_UUID:?ESP_UUID required — run ./lfs-build.sh configure}"

lfs_script_guard

lfs_mount_boot_if_needed
lfs_mount_esp

if [[ -d /sys/firmware/efi ]]; then
  mountpoint -q /sys/firmware/efi/efivars 2>/dev/null || \
    mount -t efivarfs efivarfs /sys/firmware/efi/efivars
fi

case "${GRUB_INSTALL_MODE}" in
  removable)
    grub-install --target=x86_64-efi --removable
    ;;
  efibootmgr)
    grub-install --target=x86_64-efi --bootloader-id="${GRUB_BOOTLOADER_ID}" --recheck
    ;;
  *)
    echo "Unknown GRUB_INSTALL_MODE=${GRUB_INSTALL_MODE}" >&2
    exit 1
    ;;
esac

INITRD_LINE=""
if [[ "${USE_INITRAMFS}" == "1" && -f "/boot/initrd.img-${KERNEL_RELEASE}" ]]; then
  INITRD_LINE="  initrd /boot/initrd.img-${KERNEL_RELEASE}"
fi

install -d -m755 /boot/grub
cat >/boot/grub/grub.cfg <<EOF
# Begin /boot/grub/grub.cfg (generated — UUID-based)
set default=0
set timeout=5

insmod part_gpt
insmod ext2
insmod fat

search --no-floppy --fs-uuid --set=root ${ROOT_UUID}

insmod efi_gop
insmod efi_uga
if loadfont /boot/grub/fonts/unicode.pf2; then
  terminal_output gfxterm
fi

menuentry "GNU/Linux, Linux ${KERNEL_RELEASE}" {
  linux   /boot/vmlinuz-${KERNEL_RELEASE} root=UUID=${ROOT_UUID} ro
${INITRD_LINE}
}

menuentry "Firmware Setup" {
  fwsetup
}
# End /boot/grub/grub.cfg
EOF

