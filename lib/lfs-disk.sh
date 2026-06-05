# Disk / UUID helpers (sourced after config/vars.sh).
# shellcheck shell=bash

lfs_require_disk_config() {
  : "${ROOT_UUID:?Set ROOT_UUID — run: sudo ./lfs-build.sh configure}"
  : "${ROOT_FSTYPE:?Set ROOT_FSTYPE — run: sudo ./lfs-build.sh configure}"
}

lfs_mount_root() {
  lfs_require_disk_config
  mkdir -p "${LFS}"
  if mountpoint -q "${LFS}"; then
    return 0
  fi
  mount -U "${ROOT_UUID}" -t "${ROOT_FSTYPE}" "${LFS}"
}

lfs_mount_esp() {
  : "${ESP_UUID:?ESP_UUID required for UEFI boot}"
  : "${ESP_MOUNT:?}"
  mkdir -p "${ESP_MOUNT}"
  if mountpoint -q "${ESP_MOUNT}"; then
    return 0
  fi
  mount -U "${ESP_UUID}" -t vfat \
    -o codepage=437,iocharset=iso8859-1 "${ESP_MOUNT}"
}

lfs_mount_boot_if_needed() {
  if mountpoint -q /boot 2>/dev/null; then
    return 0
  fi
  if grep -q '[[:space:]]/boot[[:space:]]' /etc/fstab 2>/dev/null; then
    mount /boot
  fi
}
