#!/bin/bash
set -euo pipefail
# System identity and network stack (config/build.conf).
# Deliberately not a verbatim LFS ch.9 paste: interface-agnostic matching,
# systemd-resolved integration, and an explicit offline (none) mode.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/lfs-common.sh"

lfs_script_guard

: "${HOSTNAME:?}"
: "${DOMAIN:?}"
: "${NETWORK_MODE:?}"

OS_NAME="${OS_NAME:-${OS_NAME_DEFAULT:-AryaLinux}}"
OS_VERSION="${OS_VERSION:-${OS_VERSION_DEFAULT:-2026.06}}"
OS_CODENAME="${OS_CODENAME:-${OS_CODENAME_DEFAULT:-Lazarus}}"

FQDN="${HOSTNAME}.${DOMAIN}"
NETWORK_MODE="${NETWORK_MODE,,}"

# --- System identity (always) ---

printf '%s\n' "${HOSTNAME}" >/etc/hostname
hostnamectl set-hostname "${HOSTNAME}" 2>/dev/null || true

cat >/etc/hosts <<EOF
# Managed by AryaLinux builder — nss-myhostname also resolves ${HOSTNAME}
127.0.0.1  localhost
127.0.1.1  ${FQDN} ${HOSTNAME}

::1        localhost ip6-localhost ip6-loopback
ff02::1    ip6-allnodes
ff02::2    ip6-allrouters
EOF

cat >/etc/os-release <<EOF
NAME="${OS_NAME}"
VERSION="${OS_VERSION}"
VERSION_CODENAME="${OS_CODENAME}"
ID=aryalinux
ID_LIKE=lfs
PRETTY_NAME="${OS_NAME} ${OS_VERSION} (${OS_CODENAME})"
HOME_URL="https://aryalinux.org/"
SUPPORT_URL="https://aryalinux.org/"
EOF
ln -sf ../os-release /etc/lsb-release

issue_text="${SYSTEM_ISSUE:-${OS_NAME} ${OS_VERSION} (${OS_CODENAME})}"
cat >/etc/issue <<EOF
${issue_text}
Kernel \\r on \\m

EOF

# --- Network stack ---

net_dir=/etc/systemd/network
mkdir -p "${net_dir}"

# Prefer classic ethN names; predictable names need sysfs/udev at runtime.
ln -sf /dev/null "${net_dir}/99-default.link"

# Drop only our own drop-ins so re-runs stay idempotent.
rm -f "${net_dir}"/10-aryalinux-*.network

# A host resolv.conf copied into the chroot blocks systemd-resolved on first boot.
if [[ -e /etc/resolv.conf && ! -L /etc/resolv.conf ]]; then
  rm -f /etc/resolv.conf
fi

lfs_enable_unit() {
  systemctl enable "$1" 2>/dev/null || true
}

lfs_disable_unit() {
  systemctl disable "$1" 2>/dev/null || true
}

write_dhcp_network() {
  cat >"${net_dir}/10-aryalinux-wired.network" <<'EOF'
[Match]
Name=en* eth*

[Network]
DHCP=ipv4
IPv6AcceptRA=yes
LinkLocalAddressing=ipv6

[DHCPv4]
UseDomains=true
RouteMetric=100
EOF

  cat >"${net_dir}/10-aryalinux-wireless.network" <<'EOF'
[Match]
Name=wl*

[Network]
DHCP=ipv4
IPv6AcceptRA=yes
LinkLocalAddressing=ipv6

[DHCPv4]
UseDomains=true
RouteMetric=200
EOF
}

write_static_network() {
  local dns_line dns
  : "${STATIC_IP:?}"
  : "${GATEWAY:?}"
  : "${DNS:?}"

  if [[ "${STATIC_IP}" != */* ]]; then
    echo "STATIC_IP must include a prefix length (e.g. 192.168.1.10/24): ${STATIC_IP}" >&2
    exit 1
  fi

  {
    echo '[Match]'
    echo 'Name=en* eth* wl*'
    echo
    echo '[Network]'
    echo "Address=${STATIC_IP}"
    echo "Gateway=${GATEWAY}"
    for dns in ${DNS}; do
      echo "DNS=${dns}"
    done
    if [[ -n "${DOMAIN}" && "${DOMAIN}" != localdomain ]]; then
      echo "Domains=${DOMAIN}"
    fi
    echo 'IPv6AcceptRA=no'
  } >"${net_dir}/10-aryalinux-static.network"
}

case "${NETWORK_MODE}" in
  dhcp)
    write_dhcp_network
    lfs_enable_unit systemd-networkd
    lfs_enable_unit systemd-resolved
    lfs_disable_unit systemd-networkd-wait-online
    ;;
  static)
    write_static_network
    lfs_enable_unit systemd-networkd
    lfs_enable_unit systemd-resolved
    lfs_disable_unit systemd-networkd-wait-online
    ;;
  none)
    lfs_disable_unit systemd-networkd
    lfs_disable_unit systemd-networkd-wait-online
    # Keep resolved: glibc nss uses it and it still serves local names.
    lfs_enable_unit systemd-resolved
    ;;
  *)
    echo "Unknown NETWORK_MODE=${NETWORK_MODE} (expected dhcp, static, or none)" >&2
    exit 1
    ;;
esac
