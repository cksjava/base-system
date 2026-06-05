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

# Unmount $LFS and every nested mount (sources bind, kernfs from phase 21, etc.).
lfs_umount_lfs_tree() {
  local lfs="${1:-${LFS:?}}"
  local mp

  if ! mountpoint -q "${lfs}" 2>/dev/null; then
    echo "Not mounted: ${lfs}"
    return 0
  fi

  echo "Unmounting all filesystems under ${lfs}..."

  if command -v fuser >/dev/null 2>&1; then
    echo "Processes using ${lfs} (close these shells / chroot sessions first):"
    fuser -vm "${lfs}" 2>/dev/null || true
  fi

  if umount -R -l "${lfs}" 2>/dev/null; then
    echo "Unmounted ${lfs}"
    return 0
  fi

  # Fallback: deepest mount points first, then lazy umount.
  for _ in 1 2 3 4 5; do
    mountpoint -q "${lfs}" 2>/dev/null || return 0
    while IFS= read -r mp; do
      [[ -n "${mp}" ]] || continue
      umount -l "${mp}" 2>/dev/null || umount "${mp}" 2>/dev/null || true
    done < <(findmnt -rn -o TARGET --submounts "${lfs}" 2>/dev/null | awk '{ print length, $0 }' | sort -rn | cut -d' ' -f2-)
    umount -l "${lfs}" 2>/dev/null || umount "${lfs}" 2>/dev/null || true
  done

  if mountpoint -q "${lfs}" 2>/dev/null; then
    echo "Still busy: ${lfs}" >&2
    echo "  cd out of ${lfs}, kill any chroot, then: sudo ./lfs-build.sh teardown" >&2
    return 1
  fi
}

lfs_format_root_partition() {
  lfs_require_disk_config
  : "${ROOT_PARTITION:?ROOT_PARTITION required — run: sudo ./lfs-build.sh configure}"

  local fstype="${ROOT_FSTYPE:-ext4}"
  echo "Formatting ${ROOT_PARTITION} as ${fstype} (all data on this partition will be destroyed)..."

  case "${fstype}" in
    ext4) mkfs.ext4 -F "${ROOT_PARTITION}" ;;
    ext3) mkfs.ext3 -F "${ROOT_PARTITION}" ;;
    xfs) mkfs.xfs -f "${ROOT_PARTITION}" ;;
    btrfs) mkfs.btrfs -f "${ROOT_PARTITION}" ;;
    *)
      echo "Unsupported ROOT_FSTYPE=${fstype} (supported: ext4, ext3, xfs, btrfs)" >&2
      return 1
      ;;
  esac
}
