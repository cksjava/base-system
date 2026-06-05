# Default values for prompts and non-disk settings (safe to commit).
# Machine-specific values live in config/build.conf (generated, gitignored).

# --- Disk (partition paths are only used to discover UUIDs) ---
export LFS_DEFAULT="${LFS_DEFAULT:-/mnt/lfs}"
export ROOT_PARTITION_DEFAULT="${ROOT_PARTITION_DEFAULT:-/dev/sda2}"
export ESP_PARTITION_DEFAULT="${ESP_PARTITION_DEFAULT:-/dev/sda1}"
export SWAP_PARTITION_DEFAULT="${SWAP_PARTITION_DEFAULT:-/dev/sda3}"
export ROOT_FSTYPE_DEFAULT="${ROOT_FSTYPE_DEFAULT:-ext4}"

# --- Boot / kernel ---
export LFS_TGT="${LFS_TGT:-$(uname -m)-lfs-linux-gnu}"
export LINUX_VERSION="${LINUX_VERSION:-6.18.10}"
export KERNEL_RELEASE="${KERNEL_RELEASE:-${LINUX_VERSION}-lfs-13.0-systemd}"
export LINUX_TARBALL="linux-${LINUX_VERSION}.tar.xz"
export LINUX_DIR="linux-${LINUX_VERSION}"
export ESP_MOUNT="${ESP_MOUNT:-/boot/efi}"
export GRUB_BOOTLOADER_ID="${GRUB_BOOTLOADER_ID:-LFS}"
export GRUB_INSTALL_MODE="${GRUB_INSTALL_MODE:-removable}"
export USE_INITRAMFS="${USE_INITRAMFS:-1}"

# --- System identity (LFS ch.9 network, ch.11 reboot) ---
export OS_NAME_DEFAULT="${OS_NAME_DEFAULT:-AryaLinux}"
export OS_VERSION_DEFAULT="${OS_VERSION_DEFAULT:-2026.06}"
export OS_CODENAME_DEFAULT="${OS_CODENAME_DEFAULT:-Lazarus}"
export HOSTNAME_DEFAULT="${HOSTNAME_DEFAULT:-aryalinux}"
export DOMAIN_DEFAULT="${DOMAIN_DEFAULT:-localdomain}"
export SYSTEM_ISSUE_DEFAULT="${SYSTEM_ISSUE_DEFAULT:-${OS_NAME_DEFAULT} ${OS_VERSION_DEFAULT} (${OS_CODENAME_DEFAULT})}"

# --- Locale / time / console (LFS ch.9) ---
export LANG_DEFAULT="${LANG_DEFAULT:-en_IN.UTF-8}"
export LC_COLLATE_DEFAULT="${LC_COLLATE_DEFAULT:-}"
export LC_TIME_DEFAULT="${LC_TIME_DEFAULT:-}"
export TIMEZONE_DEFAULT="${TIMEZONE_DEFAULT:-Asia/Kolkata}"
export HWCLOCK_UTC_DEFAULT="${HWCLOCK_UTC_DEFAULT:-1}"
export KEYMAP_DEFAULT="${KEYMAP_DEFAULT:-us}"
export CONSOLE_FONT_DEFAULT="${CONSOLE_FONT_DEFAULT:-Lat2-Terminus16}"

# --- Groff (LFS ch.8) ---
export GROFF_PAPER_SIZE_DEFAULT="${GROFF_PAPER_SIZE_DEFAULT:-A4}"

# --- Users (set after shadow in chroot) ---
export SYSTEM_USER_DEFAULT="${SYSTEM_USER_DEFAULT:-aryalinux}"
export ROOT_PASSWORD_DEFAULT="${ROOT_PASSWORD_DEFAULT:-aryalinux}"
export USER_PASSWORD_DEFAULT="${USER_PASSWORD_DEFAULT:-aryalinux}"

# --- Network (LFS ch.9) ---
export NETWORK_MODE_DEFAULT="${NETWORK_MODE_DEFAULT:-dhcp}"
export STATIC_IP_DEFAULT="${STATIC_IP_DEFAULT:-192.168.1.100/24}"
export GATEWAY_DEFAULT="${GATEWAY_DEFAULT:-192.168.1.1}"
export DNS_DEFAULT="${DNS_DEFAULT:-8.8.8.8}"
