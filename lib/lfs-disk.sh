# Disk helpers (sourced after config/vars.sh).
# Host mounts use partition paths; UUIDs are for fstab/grub on the built system.
# shellcheck shell=bash

lfs_require_disk_config() {
  : "${ROOT_FSTYPE:?Set ROOT_FSTYPE — run: sudo ./lfs-build.sh configure}"
  if [[ -z "${ROOT_PARTITION:-}" && -z "${ROOT_UUID:-}" ]]; then
    echo "Set ROOT_PARTITION or ROOT_UUID — run: sudo ./lfs-build.sh configure" >&2
    return 1
  fi
  : "${ROOT_UUID:?Set ROOT_UUID — run: sudo ./lfs-build.sh configure}"
}

lfs_mount_root() {
  lfs_require_disk_config
  mkdir -p "${LFS}"
  if mountpoint -q "${LFS}"; then
    return 0
  fi
  if [[ -n "${ROOT_PARTITION:-}" && -b "${ROOT_PARTITION}" ]]; then
    mount -t "${ROOT_FSTYPE}" "${ROOT_PARTITION}" "${LFS}"
  else
    mount -U "${ROOT_UUID}" -t "${ROOT_FSTYPE}" "${LFS}"
  fi
}

lfs_mount_esp() {
  : "${ESP_MOUNT:?}"
  mkdir -p "${ESP_MOUNT}"
  if mountpoint -q "${ESP_MOUNT}"; then
    return 0
  fi
  if [[ -n "${ESP_PARTITION:-}" && -b "${ESP_PARTITION}" ]]; then
    mount -t vfat -o codepage=437,iocharset=iso8859-1 \
      "${ESP_PARTITION}" "${ESP_MOUNT}"
  elif [[ -n "${ESP_UUID:-}" ]]; then
    mount -U "${ESP_UUID}" -t vfat \
      -o codepage=437,iocharset=iso8859-1 "${ESP_MOUNT}"
  else
    echo "ESP_PARTITION or ESP_UUID required for UEFI boot — run configure" >&2
    return 1
  fi
}

lfs_mount_boot_if_needed() {
  if mountpoint -q /boot 2>/dev/null; then
    return 0
  fi
  if grep -q '[[:space:]]/boot[[:space:]]' /etc/fstab 2>/dev/null; then
    mount /boot
  fi
}
