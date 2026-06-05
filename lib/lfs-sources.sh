# LFS ch.3 sources — host cache, bind mount on $LFS, copy before chroot.
# shellcheck shell=bash
#
# Book (ch.3): mkdir $LFS/sources on the mounted partition, chmod a+wt, wget in.
#
# This builder:
#   1. Download to <parent-of-builder>/sources on the host (outside $LFS).
#   2. After mounting $LFS: mount --bind <host-cache> $LFS/sources (ch.5–6),
#      same bind-mount style as $LFS/dev in ch.7 kernfs.
#   3. Before chroot: umount the bind, mkdir a real $LFS/sources on the
#      partition, chmod a+wt, and copy everything from the host cache.

lfs_sources_cache_dir() {
  : "${ROOT:?ROOT must be set}"
  local parent
  parent="$(cd "${ROOT}/.." && pwd)"
  echo "${parent}/sources"
}

lfs_sources_wget_list() {
  : "${ROOT:?}"
  echo "${ROOT}/13.0/wget-list-systemd"
}

lfs_sources_md5sums_file() {
  : "${ROOT:?}"
  echo "${ROOT}/13.0/md5sums"
}

lfs_sources_cache_ready() {
  local cache=${1:-$(lfs_sources_cache_dir)}
  [[ -d "${cache}" ]]
}

lfs_sources_verify_md5() {
  local dir=$1

  [[ -f "${dir}/md5sums" ]] || return 0
  (
    cd "${dir}"
    md5sum -c md5sums
  )
}

lfs_sources_is_bind_mounted() {
  local dest="${LFS:?}/sources"
  mountpoint -q "${dest}" 2>/dev/null
}

lfs_unmount_sources_bind() {
  local dest="${LFS:?}/sources"
  if lfs_sources_is_bind_mounted; then
    umount -v "${dest}"
  fi
}

# Step 1 — host download (not on the LFS partition).
lfs_ensure_sources_cache() {
  local cache wget_list md5_src

  cache="$(lfs_sources_cache_dir)"
  wget_list="$(lfs_sources_wget_list)"
  md5_src="$(lfs_sources_md5sums_file)"

  if lfs_sources_cache_ready "${cache}"; then
    echo "Sources cache present: ${cache}"
    return 0
  fi

  echo "=== Downloading LFS sources (ch.3) into host cache: ${cache} ==="

  if [[ ! -f "${wget_list}" ]]; then
    echo "Missing wget list: ${wget_list}" >&2
    exit 1
  fi
  if [[ ! -f "${md5_src}" ]]; then
    echo "Missing checksum file: ${md5_src}" >&2
    exit 1
  fi
  if ! command -v wget >/dev/null 2>&1; then
    echo "wget is required to download sources (LFS ch.3)." >&2
    exit 1
  fi

  mkdir -pv "${cache}"
  chmod -v a+wt "${cache}"

  wget --input-file="${wget_list}" --continue --directory-prefix="${cache}"
  cp -v "${md5_src}" "${cache}/md5sums"
  lfs_sources_verify_md5 "${cache}"

  chown -R root:root "${cache}"/* 2>/dev/null || true

  echo "Sources cache ready: ${cache}"
}

# Step 2 — after $LFS is mounted: bind-mount host cache at $LFS/sources.
lfs_bind_mount_sources_on_lfs() {
  local cache dest
  : "${LFS:?LFS must be set}"

  cache="$(cd "$(lfs_sources_cache_dir)" && pwd)"
  dest="${LFS}/sources"

  if ! lfs_sources_cache_ready "${cache}"; then
    echo "Sources cache missing: ${cache}" >&2
    exit 1
  fi

  chmod -v a+wt "${cache}"

  if lfs_sources_is_bind_mounted; then
    echo "\$LFS/sources already bind-mounted"
    return 0
  fi

  if [[ -d "${dest}" && ! -L "${dest}" ]]; then
    echo "\$LFS/sources is already a directory on the target partition (skipping bind mount)"
    chmod -v a+wt "${dest}"
    return 0
  fi

  rm -rf "${dest}"
  mkdir -pv "${dest}"
  mount -v --bind "${cache}" "${dest}"
  echo "Bind-mounted ${cache} -> ${dest}"
}

# Step 3 — before chroot: umount bind, real directory on partition, copy cache.
lfs_copy_sources_into_lfs() {
  local cache dest
  : "${LFS:?LFS must be set}"

  cache="$(lfs_sources_cache_dir)"
  dest="${LFS}/sources"

  if ! lfs_sources_cache_ready "${cache}"; then
    echo "Sources cache missing: ${cache}" >&2
    exit 1
  fi

  lfs_unmount_sources_bind

  if [[ -L "${dest}" ]]; then
    rm -f "${dest}"
  elif [[ -d "${dest}" ]]; then
    echo "Merging host cache into existing ${dest}"
    rsync -a "${cache}/" "${dest}/"
    chmod -v a+wt "${dest}"
    if [[ -f "${dest}/md5sums" ]]; then
      lfs_sources_verify_md5 "${dest}"
    fi
    chown -R root:root "${dest}"/* 2>/dev/null || true
    return 0
  fi

  mkdir -pv "${dest}"
  chmod -v a+wt "${dest}"

  echo "Copying sources from ${cache} onto LFS partition at ${dest}"
  rsync -a "${cache}/" "${dest}/"

  if [[ -f "${dest}/md5sums" ]]; then
    lfs_sources_verify_md5 "${dest}"
  fi

  chown -R root:root "${dest}"/* 2>/dev/null || true
}

# Materialize when entering chroot or before chown of $LFS tree.
lfs_ensure_sources_on_partition() {
  if lfs_sources_is_bind_mounted || [[ -L "${LFS}/sources" ]] || [[ ! -d "${LFS}/sources" ]]; then
    lfs_copy_sources_into_lfs
  fi
}
